# README

## Configuration

You should configure your profile this way in `~/.aws/config`

```
[plugins]
endpoint = awscli_plugin_endpoint

[profile idt]
aws_access_key_id =
aws_secret_access_key =
region = bhs
s3 =
  endpoint_url = https://s3.bhs.io.cloud.ovh.net
  signature_version = s3v4
s3api =
  endpoint_url = https://s3.bhs.io.cloud.ovh.net
```

## Installation

Use IDT aws profile for storing credentials :

```
export AWS_PROFILE=idt
```

```
tf init
tf apply
```
