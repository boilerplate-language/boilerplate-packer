# boilerplate-packer

Template for packer

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
packer validate boilerplate.pkr.hcl
```

### イメージのビルド

```bash
packer build boilerplate.pkr.hcl
```
