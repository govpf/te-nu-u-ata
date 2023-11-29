# Déploiement

## Déployer en staging

### Récupération d’un kubeconfig

### Déploiement

On se positionne d’abord dans le cluster idt, avec [kctx](https://github.com/ahmetb/kubectx).

```
kctx idt
```

Puis on lance le déploiement avec helm :

```
helm upgrade -i staging-mes-demarches -f staging.yaml --namespace staging mes-demarches/1.0.0
```

La configuration applicative se trouve dans le fichier values.yaml.

S’il s’agit de données non sensibles elles sont à mettre directement dans ce fichier. Dans le cas contraire elles doivent être provisionnées en tant que secret avec Terraform et on y fait référence dans le fichier de values.
