# boilerplate-packer

Template for packer

[![Terraform](https://github.com/kannkyo/boilerplate-packer/actions/workflows/terraform-publish.yml/badge.svg)](https://github.com/kannkyo/boilerplate-packer/actions/workflows/terraform-publish.yml)
[![terraform ci](https://github.com/kannkyo/boilerplate-packer/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/kannkyo/boilerplate-packer/actions/workflows/terraform-ci.yml)

## 開発方法

### 事前準備

IAM ロールを用意しておく。

### terraform初期化

```bash
cd terraform
terraform init
terraform apply
```

### ファイルのフォーマット

```bash
packer fmt .
```

### イメージの検証

```bash
packer validate .
```

### イメージのビルド

#### 新規作成

```bash
packer build .
```

#### 再作成（AMIイメージ上書き）

```bash
packer build -force .
```

## Tips

### AWSイメージの探し方

まず、AWS コンソールの[AMIカタログ](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#AMICatalog:)で検索して、AMI ID を確認する。

次に、AWS CLI で AWS イメージの詳細を確認する。

```bash
aws ec2 describe-images --image-ids <AMI_ID> --owners <OWNER> --filters <FILTER>
```

例は以下。

```bash
aws ec2 describe-images --image-ids ami-0cdc4f61f73af4679
```

### インスタンスタイプの探し方

AWS コンソールの[インスタンスタイプ](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#InstanceTypes:)で検索する。

### テストのローカル実行

```bash
goss --gossfile ./tests/goss.yaml validate
```
