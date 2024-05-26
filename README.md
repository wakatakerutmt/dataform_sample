
以下作業記録

## CLIでのdataformプロジェクトの作成履歴

### dockerに入る

```
$docker-compose up -d
$make in
```

### dataformのプロジェクト雛形作成
```
/workdir # dataform init workflow-project iida-test-423114 asia-northeast1
```

### 認証情報の作成
サービスアカウントのキーファイルをworkflow-project直下に配置する（`workflow-project/service-account.json`）
次に認証情報を作成する
```
/workdir # cd workflow-project/
/workdir/workflow-project # dataform init-creds

[1] US (default)
[2] EU
[3] other

Enter the location of your datasets [1, 2, 3]: 3
Enter the location's region name (e.g. 'asia-south1'):
> asia-northeast1

[1] ADC (default)
[2] JSON Key

Do you wish to use Application Default Credentials or JSON Key [1/2]: 2
Please follow the instructions at https://docs.dataform.co/dataform-cli#create-a-credentials-file/
to create and download a private key from the Google Cloud Console in JSON format.
(You can delete this file after credential initialization is complete.)

Enter the path to your Google Cloud private key file:
> service-account.json                             

Running connection test...
(node:73) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
(Use `node --trace-deprecation ...` to show where the warning was created)

Credentials test query completed successfully.

Credentials file successfully written:
  /workdir/workflow-project/.df-credentials.json
To change connection settings, edit this file directly.
```

`workflow-project/.df-credentials.json`ができていたらOK

### データセットの設定

workflow_settings.yamlのデータセット名を使用するものに変更する
```
defaultDataset: dataform_sample
```

### ワークフローファイルの作成
workflow-project/definitions以下にsourcesディレクトリと、tablesディレクトリを作成して各sqlxファイルを作成する

### ワークフローの実行

```
/workdir/workflow-project # dataform run
Compiling...

(node:113) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
Compiled successfully.

Running...

Table created:  dataform_sample.customers [table]
```

## Git連携

dockerから抜けて、手元でsshキーを作成
```
ssh-keygen -t ed25519
```

これをGitHubのリポジトリのデプロイキーに設定する

SETTING > GIT連携から連携する

シークレットマネージャーに秘密鍵を登録し、サービスアカウトにIAMのSecret Managerの権限付与が必要

公開鍵のKey-Valueの入力はknown_hostから取得する必要あり


## Gitのブランチをdataformのワークスペースを同期する方法

1. 手元でブランチ作ってPUSHする
2. dataformで同じ名前のワークスペースを作成する
3. dataform上でPULLができるようになっているのでする。


## workflow_settings.yamlはプロジェクトルートに必要

workflow_settings.yamlファイルが、wortflow-projectディレクトリ以下に入っていたがこれではdataform上でワークフローの実行ができなかった（認識されなかった）ので
workflow-projectディレクトリは削除して中のファイルをルートに移した。

そしてdataform上でworkflow_settings.yamlを開いてパッケージのインストールを行うことで、実行（EXECUTION）できるようになった


## CIの利用

認証は.df-credentials.jsonの暗号化したものをコミットに含めて置き、それをCI上で復号して使う

認証ファイルの暗号化は以下で行う（パスフレーズの設定が求められる）

gpgが入ってない場合は入れる
```
brew install gpg
```

```
gpg --symmetric --cipher-algo AES256 .df-credentials.json
```

パスフレーズはGitHubのsecretに登録して用いる

復号は以下のコマンドで可能
```
gpg --quiet --batch --yes --decrypt --passphrase="$CREDENTIALS_GPG_PASSPHRASE" --output .df-credentials.json .df-credentials.json.gpg
```