# README

On utilise des IP publiques pendant la phase de setup.

## Installation

On commence par créer le fichier contenant le mot de passe du vault.

```
echo "XXX" > ~/ansible_vault_idt
```

Quelques modules doivent être installés localement au préalable.

```bash
pip install --user passlib
pip install --user psycopg2
```

Puis on installe les dépendances :

```bash
ansible-galaxy install -r requirements.yml
```

### Firewall

On part d’une liste blanche, on ouvre uniquement ce dont on a besoin et on ferme tout le reste.

```bash
ansible-playbook -i inventory firewall.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```


### Databases

Il est nécessaire d'installer les paquets postgresql et pgpool avant.

Si on laisse le rôle `geerlingguy.postgresql` le faire dans le playbook databases, il installe pg13 par défaut, alors que nous voulons pg15.

Nous utilisons pour cela notre playbook de préparation `prepare_postgresql.yml`:

```bash
ansible-playbook -i inventory prepare_postgresql.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

puis :

```bash
ansible-playbook -i inventory configure_postgresql.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

Sur les machines concernées on peut vérifier qu’on peut se connecter :

```
psql -h localhost -U k3s k3s_production
```

### PG Pool II

On lance le playbook de préparation qui va s'occuper de copier les fichiers nécessaires :

```bash
ansible-playbook -i inventory_pg_pool.yml prepare_pgpool.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

Puis on lance le playbook de configuration :

```bash
ansible-playbook -i inventory_pg_pool.yml configure_pgpool.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

La configuration du pgpool se trouve dans `/etc/pgpool2/pgpool.conf`.
Les logs dans `/var/log/pgpool/pgpool.log`.

Pour vérifier que tout fonctionne bien, on se connecte avec pgpool.

L'hôte pgpool pointe vers l'IP virtuelle du service qui balance entre les deux services du pool.

```bash
psql -h pgpool -p 9999 -U postgres
```

```
show pool_nodes;
```

On doit obtenir le retour suivant :

```
node_id |   hostname   | port | status | lb_weight |  role   | select_cnt | load_balance_node | replication_delay | replication_state | replication_sync_state | last_status_change
---------+--------------+------+--------+-----------+---------+------------+-------------------+-------------------+-------------------+------------------------+---------------------
 0       | postgresql01 | 5432 | up     | 0.500000  | primary | 1          | true              | 0                 |                   |                        | 2023-07-18 23:25:48
 1       | postgresql02 | 5432 | up     | 0.500000  | standby | 0          | false             | 31268056          |                   |                        | 2023-07-18 23:25:48
(2 rows)
```

### Droits nécessaires sur le schéma public

Les droits par défaut sur le schema public ont changé avec postgresql 15, seul le owner de la db dispose de droits permettant de manipuler la base de données.

La base de données étant créé avec l'utilisateur `postgres` et utilisée avec un utilisateur dédié, nous devons donner les droits à ce dernier.

```
psql -h pgpool -p 9999 -U postgres k3s_production
GRANT ALL ON SCHEMA public TO k3s;
```

/!\ Cette partie n'est pas automatisée et a été faite manuellement (à faire pour chaque DB, une seule fois).

### k3s

```bash
ansible-playbook -i inventory prepare_k3s.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

```bash
ansible-playbook -i inventory configure_k3s.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

```bash
journalctl -u k3s -f
```

```
systemctl status k3s.service
```

Le token master peut être trouvé ici :

```
/var/lib/rancher/k3s/server/token
```

Le fichier `.kubeconfig` :

```
/etc/rancher/k3s/k3s.yaml
```

La configuration de k3s :

```
/etc/rancher/k3s/config.yaml
```

### Bastion

Le bastion est une VM utilisée à l'intérieur du pool d'IP pour lancer les commandes sur les VM cibles.

Elle est aussi utilisées pour synchroniser les attachments depuis outscale vers l'object storage de OVH.

Une fois le k3s provisionné on récupère le `.kubeconfig` pour le copier sur le bastion afin que le cluster soit accessible via `kubectl`.

```bash
ansible-playbook -i inventory prepare_bastion.yml --vault-password-file=~/ansible_vault_idt  -e@./credentials.yml
```

```bash
ansible-playbook -i inventory configure_bastion.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```

### Rancher

```bash
ansible-playbook -i inventory configure_rancher.yml --vault-password-file=~/ansible_vault_idt -e@./credentials.yml
```


## Droits

On veut que :

- en local (localhost) l'accès à pg et pgpool avec l'utilisateur postgres se fasse sans mot de passe (trust)
- sur le pool d'IP publiques réservés, l'accès à pg et pgpool se fait en trust pour l'utilisateur postgres sur toutes les bases
- sur le pool d'IP publiques réservés, l'accès à pg et pgpool se fait en scram-sha-256 pour les autres utilisateurs
- depuis les autres IP il n'est pas possible de se connecter

Les fichiers de configuration concernés sont le suivants :

```
/etc/postgresql/15/main/pg_hba.conf
```

```
/etc/pgpool2/pool_hba.conf
```

/!\ Ils ne doivent pas être mis à jour manuellement, uniquement avec les playbook.

## Vérifications

```
systemctl status pgpool2.service
```

```
systemctl status postgresql@15-main.service
```

```
systemctl status
```

```
pg_md5 --config-file=/etc/pgpool2/pgpool.conf --md5auth --username=user password
```

```
pg_enc -m -f /etc/pgpool2/pgpool.conf -u username -p
```

```
k3s_production=> SHOW password_encryption;
 password_encryption
---------------------
 scram-sha-256
```

```
/etc/postgresql/15/main/postgresql.conf
```

```
/etc/postgresql/15/main/pg_hba.conf
```

```
/etc/pgpool2/pool_hba.conf
```

systemctl restart pgpool2
systemctl restart postgresql@15-main.service

psql -h postgresql02 -U k3s k3s_production

psql -p 9999 -h pgpool -U k3s k3s_production
