# アクセスログバケットが既に AWS 上に存在する場合のみ import が実行される。
# 存在しない場合は terraform apply で新規作成されるため、このファイルを削除してから apply すること。
# initial apply 完了後はこのファイルを削除する。

import {
  to = module.state_access_logs_bucket.aws_s3_bucket.this[0]
  id = "${var.state_bucket_name}-access-logs"
}
