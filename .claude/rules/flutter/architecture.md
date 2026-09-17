# Flutter Architecture Rules

## 1. 基本方針

Flutterアプリは、責務を明確に分離し、変更の影響範囲を局所化できる構造とする。

アーキテクチャ上の分離を目的として、不要なレイヤーやファイルを機械的に増やさない。

コードの責務、依存方向、可読性、テスト容易性を優先する。

## 2. レイヤー構成

基本的に以下のレイヤーを使用する。

```text
Presentation
    ↓
Domain
    ↓
Data
```

### Presentation

UIと画面状態を担当する。

主な責務:

* Page
* Widget
* UI State
* ViewModel / Notifier
* Riverpod Provider
* ユーザー操作の受付
* UIへの状態反映

PresentationからData層の具体実装を直接参照しない。

### Domain

アプリケーションの業務ルールとユースケースを担当する。

主な責務:

* Entity
* Repository Interface
* UseCase
* 業務ロジック

DomainはFlutterのUI実装、API、SQLite、外部SDKなどの具体的な実装に依存しない。

可能な限り、フレームワークやインフラストラクチャから独立した状態を維持する。

### Data

外部データソースや永続化処理など、具体的なデータアクセスを担当する。

主な責務:

* Repository Implementation
* DataSource
* API
* SQLite
* 外部SDK
* DTO
* Mapper
* データ取得・保存処理

Data層はDomainで定義されたRepository Interfaceを実装する。

## 3. 依存方向

基本的な依存方向は以下とする。

```text
Presentation → Domain
Data         → Domain
```

DomainからPresentationやDataへ依存しない。

PresentationからDataの具体実装へ直接依存しない。

DataからPresentationへ依存しない。

循環依存を作らない。

## 4. Repository

Repositoryは、データ取得・保存の詳細をPresentationやDomainから隠蔽するために使用する。

Repository Interfaceは原則としてDomain側に定義し、
具体的なRepository ImplementationはData側に定義する。

```text
Domain
└── UserRepository

Data
└── UserRepositoryImpl
```

ただし、単純な処理に対して形式的にRepositoryを増やすことを目的としない。

既存のRepositoryで責務を明確に表現できる場合は、不要なRepositoryを追加しない。

## 5. UseCase

UseCaseは、アプリケーション上のユースケースや業務ロジックを表現するために使用する。

複数の処理を組み合わせる場合や、業務ルールを持つ場合はUseCaseへの分離を検討する。

単純にRepositoryのメソッドを1回呼び出すだけの処理に対して、
機械的にUseCaseを作成しない。

UseCaseの有無は、処理の責務と複雑さに基づいて判断する。

## 6. State / ViewModel

画面固有の状態とUI操作に伴う処理は、Widgetに集中させず、
プロジェクトで採用している状態管理方式に従って管理する。

Riverpod ProviderおよびNotifier / ViewModelは、
画面状態の管理とPresentation層の処理を担当する。

Widgetは、UIの表示とユーザー操作の受け渡しを主な責務とする。

Widgetから直接API、SQLite、外部SDKなどを操作しない。

## 7. Riverpod

Riverpodは、主に状態管理および依存関係の提供に使用する。

Providerは、その依存関係を必要とするPresentationまたはApplication上の責務に近い場所に配置する。

Providerを単なるグローバルな処理置き場として使用しない。

RepositoryやUseCaseなどの依存関係をProviderから提供する場合は、
依存方向を壊さないようにする。

## 8. Routing

RoutingはGoRouterを使用する。

画面遷移の定義はRoutingの責務として管理し、
Widget内にアプリケーション全体の遷移ルールを分散させない。

認証状態などによって遷移先を判断する場合は、
Routingと状態管理の責務を分離する。

Domain層からGoRouterを直接操作しない。

## 9. モデル

モデルは用途に応じて責務を分離する。

### Entity

Domainで扱うアプリケーション上の概念を表現する。

### DTO

APIやデータベースなど、外部データソースとの入出力形式を表現する。

### UI State

画面表示に必要な状態を表現する。

Entity、DTO、UI Stateを、用途が異なるにもかかわらず1つのモデルで無理に共用しない。

## 10. Freezed

Freezedは、プロジェクトで必要な用途に応じて使用する。

主な用途:

* Immutableなモデル
* Union / Sealed State
* UI State
* Entity
* DTO

ただし、Freezedを使用すること自体を目的としない。

モデルの責務に応じて適切な型を設計する。

## 11. Mapper

外部データ形式とDomainモデルの変換が必要な場合はMapperを使用する。

例えば、

```text
DTO
 ↓ Mapper
Entity
```

のように、Data層の具体的なデータ形式がDomain層へ漏れない構造を基本とする。

ただし、変換処理が単純で独立した責務として扱う必要がない場合は、
不必要にMapperのファイルを増やさない。

## 12. DataSource

API、SQLite、外部SDKなど、具体的なデータアクセス処理はDataSource等に分離する。

Repositoryはデータ取得・保存の抽象的な責務を担当し、
具体的な通信・データベース操作・SDK操作の詳細を直接持たせすぎない。

ただし、単純な構造に対して機械的にDataSourceを追加しない。

## 13. エラー処理

Data層で発生した具体的な例外を、そのままPresentation層へ漏らさない。

必要に応じてData層でアプリケーション上扱いやすいエラーへ変換する。

Presentation層では、UIとして必要な状態に変換して扱う。

例:

```text
API Exception
    ↓
Data Layer
    ↓
Repository / Domainで扱えるエラー
    ↓
ViewModel / Notifier
    ↓
UI State
```

例外を理由なく握り潰さない。

## 14. コード生成ファイル

`*.g.dart`、`*.freezed.dart` などの生成ファイルは、
人間が直接編集する対象としない。

生成元となる`.dart`ファイルを編集し、
プロジェクトで定めたコード生成コマンドによって生成する。

生成ファイルをアーキテクチャ上の独立した責務として扱わない。

## 15. テスト

各層の責務に応じてテストを行う。

### Presentation

* UI状態の変化
* ユーザー操作に対する状態変更
* Widgetの表示

### Domain

* UseCaseの業務ロジック
* Entityの振る舞い
* Repository Interfaceを利用した処理

### Data

* Repository Implementation
* DTO / Mapper
* API / SQLite等とのデータ変換
* エラー処理

外部サービスやデータソースは、必要に応じてFakeやMockへ差し替えてテストする。

## 16. アーキテクチャ判断の原則

以下を優先する。

1. 責務を明確にする
2. 依存方向を維持する
3. テストしやすい構造にする
4. 変更の影響範囲を局所化する
5. 不要なレイヤーやファイルを増やさない

「Clean Architectureの要素をすべて配置すること」を目的としない。

処理の単純さに対して過剰な抽象化を行わない。

新しいRepository、UseCase、DataSource、Mapper等を追加する場合は、
その責務を分離する明確な理由があるか確認する。


