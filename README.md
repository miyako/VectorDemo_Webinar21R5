![version](https://img.shields.io/badge/version-21%20R5-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-arm%20|%20mac-intel%20|%20win-64&color=blue)

# VectorDemo_Webinar21R5

[日本語](#日本語) | [English](#english)

---

## 日本語

10 万件のサポートチケットを **意味で検索** する 4D 21 R5 のデモです。チケットの件名と内容を埋め込みベクトルに変換して `4D.Vector` フィールドに保存し、ベクトルインデックスを使った ORDA クエリで、言い回しが違っても内容の近いチケットを探します。埋め込みモデル（[ruri-v3-310m](https://huggingface.co/cl-nagoya/ruri-v3-310m)）は llama.cpp でローカル実行するので、API キーもクラウドも不要です。

### このデモでわかること

- `4D.Vector` 型のフィールドに埋め込みベクトルを保存する
- ストラクチャーで定義したコサイン類似度のベクトルインデックス（`IndexedVector`）
- `ds.Tickets.query("IndexedVector > :1"; {vector; metric: mk cosine; threshold})` による類似検索と並べ替え
- インデックスあり／なし（全件走査）の検索時間の比較
- [4D AIKit](https://github.com/4d/4D-AIKit) の OpenAI 互換 API で、ローカルの llama.cpp サーバーから埋め込みを取得する
- 埋め込みの非同期取得（`onTerminate`）と `CALL FORM` による画面更新
- XLIFF によるローカライズ（OS の言語に合わせて日本語／英語）と macOS Liquid Glass／Windows Fluent UI 向けスタイルシート

### 必要なもの

- 4D 21 R5 以降
- インターネット接続（初回のみ：コンポーネントとモデルのダウンロード）
- 空きディスク約 2 GB（データ約 830 MB、モデル約 340 MB）

### はじめかた

1. リポジトリをクローンするか、ZIP をダウンロードして展開します。
2. [Releases](../../releases) から `Data.zip` をダウンロードし、展開した `Data` フォルダーをプロジェクトのルート（`Project` と同じ階層）に置きます。
3. 4D で `Project/VectorDemo_Webinar21R5.4DProject` を開きます。依存関係マネージャーがコンポーネント（4D AIKit、llama-cpp ほか）を自動でダウンロードします。
4. 「チケット検索」ウィンドウが開きます。初回はモデル（約 340 MB）が `~/.GGUF/` にダウンロードされ、下部のステータスに進捗が表示されます。「埋め込みモデル準備完了」と表示されたら検索できます。

### デモの進めかた

1. 「質問の例」から質問を選ぶか、困りごとを自由に入力して **検索** をクリックします（例：「VPN がすぐ切れて仕事にならない」）。
2. 「ベクトルインデックスを使う」のオン／オフを切り替えて同じ質問で検索し、2 行目に表示される検索時間を比べます。
3. 「類似度 ≥」で絞り込みの閾値を変えられます。ruri-v3 は関連の薄い文章どうしでも類似度が 0.8 前後になるため、初期値は 0.87 です（例: 「Teams の会議で声が途切れる」は約 3,500 件、「パスワードを変えてからログインできない」は 48 件）。

### しくみ

- `TicketFinder` フォームの `On Load` で `cs.EmbeddingModel.new().start()` が llama.cpp サーバー（ポート 18083）を起動します。状態の変化は `ModelStatus` → `CALL FORM` → `TicketFinder_onModel` でステータス行に表示されます。
- **検索** をクリックすると `TicketFinder_search` が質問を非同期でベクトル化し、結果は `TicketFinder_onEmbedding` に届きます。ここでベクトルクエリを実行し、時間を計測します。
- 類似度の列は `This.Vector.cosineSimilarity(Form.queryVector)` で表示しています。
- 質問には `検索クエリ: `、チケットには `検索文書: ` を前置します（ruri-v3 の推奨）。
- アプリを終了すると `On Exit` でサーバーを停止します。

### データを作り直すには

```sh
python3 tools/generate_tickets_ja.py   # Resources/support_tickets_100k.csv を再生成
```

その後、`BuildDemoData` メソッドを実行すると、CSV を読み込み、埋め込みを計算し、インデックスを作り直します（10 万件で約 10 分）。tool4d でヘッドレス実行することもできます。

```sh
tool4d --project=Project/VectorDemo_Webinar21R5.4DProject --data=Data/data.4DD --create-data \
  --skip-onstartup --startup-method=BuildDemoData --user-param='{"quit":true}'
```

チケットのデータはすべて架空のものです。

---

## English

A 4D 21 R5 demo of **semantic search** over 100,000 support tickets (in Japanese). Each ticket's subject and description are turned into an embedding stored in a `4D.Vector` field, and an ORDA query on a vector index finds tickets that mean the same thing even when they are worded differently. The embedding model ([ruri-v3-310m](https://huggingface.co/cl-nagoya/ruri-v3-310m)) runs locally with llama.cpp: no API key, no cloud.

### What it demonstrates

- Storing embeddings in `4D.Vector` fields
- A cosine vector index declared in the structure (`IndexedVector`)
- Similarity search and ordering with `ds.Tickets.query("IndexedVector > :1"; {vector; metric: mk cosine; threshold})`
- Comparing search time with and without the vector index (full scan)
- Getting embeddings from a local llama.cpp server through the OpenAI-compatible API of [4D AIKit](https://github.com/4d/4D-AIKit)
- Asynchronous embedding (`onTerminate`) with UI updates through `CALL FORM`
- XLIFF localisation (Japanese or English, following the OS language) and stylesheets for macOS Liquid Glass / Windows Fluent UI

### Requirements

- 4D 21 R5 or later
- An internet connection on first launch (components and model download)
- About 2 GB of free disk space (data about 830 MB, model about 340 MB)

### Getting started

1. Clone the repository, or download and extract the ZIP.
2. Download `Data.zip` from [Releases](../../releases) and put the extracted `Data` folder at the project root, next to `Project`.
3. Open `Project/VectorDemo_Webinar21R5.4DProject` in 4D. The Dependency Manager downloads the components (4D AIKit, llama-cpp, ...).
4. The Ticket Finder window opens. On first launch the model (about 340 MB) is downloaded to `~/.GGUF/`; progress is shown in the status line. Search becomes available once the model is ready.

### Running the demo

1. Pick a sample question or type a problem in your own words, then click **Search**. The ticket data is in Japanese, so Japanese questions work best.
2. Toggle **Use the vector index** and run the same question again; the second line compares the two search times.
3. **Similarity ≥** sets the threshold. ruri-v3 gives even loosely related texts a cosine similarity around 0.8, so the default is 0.87 (e.g. about 3,500 hits for the Teams audio sample, 48 for the password sample).

### How it works

- On `On Load`, the `TicketFinder` form calls `cs.EmbeddingModel.new().start()`, which starts a llama.cpp server on port 18083. Status changes travel `ModelStatus` → `CALL FORM` → `TicketFinder_onModel`.
- **Search** calls `TicketFinder_search`, which embeds the question asynchronously; the result arrives in `TicketFinder_onEmbedding`, which runs and times the vector query.
- The score column is `This.Vector.cosineSimilarity(Form.queryVector)`.
- Questions are prefixed with `検索クエリ: ` and tickets with `検索文書: `, as recommended for ruri-v3.
- `On Exit` stops the server.

### Rebuilding the data

Run `python3 tools/generate_tickets_ja.py` to regenerate `Resources/support_tickets_100k.csv`, then run the `BuildDemoData` method to import it, compute the embeddings and rebuild the index (about 10 minutes for 100,000 tickets). It also runs headless with tool4d (see the command above).

All ticket data is fictitious.

## References

- [4D documentation: Vector class](https://developer.4d.com/docs/API/VectorClass)
- [4D documentation: ORDA query with vectors](https://developer.4d.com/docs/API/DataClassClass#query-by-vector-similarity)
- [4D AIKit](https://github.com/4d/4D-AIKit)
- [miyako/llama-cpp](https://github.com/miyako/llama-cpp)
- [cl-nagoya/ruri-v3-310m](https://huggingface.co/cl-nagoya/ruri-v3-310m) (GGUF: [Targoyle/ruri-v3-310m-GGUF](https://huggingface.co/Targoyle/ruri-v3-310m-GGUF))
