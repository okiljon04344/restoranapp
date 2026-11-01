// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ユニバーサルレストラン';

  @override
  String get welcomeTitle => 'ようこそ！';

  @override
  String get chooseLanguage => '続けるには言語を選択してください';

  @override
  String get continueBtn => '続ける →';

  @override
  String get menu => 'メニュー';

  @override
  String get cart => 'カート';

  @override
  String get orders => '注文';

  @override
  String get tableEntry => 'テーブルを選択';

  @override
  String get tableNumber => 'テーブル番号';

  @override
  String get tableHint => '1, 2, 3...';

  @override
  String get scanQr => 'QRコードをスキャン';

  @override
  String get enterTableManually => 'テーブル番号を入力';

  @override
  String get tableRequired => 'テーブル番号を入力してください';

  @override
  String get tableInvalid => 'テーブル番号は数字でなければなりません';

  @override
  String get tableOccupied => '⚠️ テーブル使用中';

  @override
  String get tableOccupiedMsg => 'このテーブルは現在使用されています。続けますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get continueAnyway => '続ける';

  @override
  String get goToMenu => 'メニューへ';

  @override
  String get checking => '確認中...';

  @override
  String qrScanned(String table) {
    return 'QRスキャン完了: テーブル $table';
  }

  @override
  String get invalidQr => '無効なQRコードです。もう一度お試しください。';

  @override
  String get scanQrDialog => 'テーブルQRをスキャン';

  @override
  String get scanQrDialogContent => 'テーブルQRをスキャンするためカメラを使用します';

  @override
  String get openCamera => 'カメラを開く';

  @override
  String get searchFood => '料理を検索...';

  @override
  String get addToCart => 'カートに追加';

  @override
  String addedToCart(String item) {
    return '$item をカートに追加しました！';
  }

  @override
  String get noItemsFound => 'アイテムが見つかりません。';

  @override
  String get yourCart => 'カート';

  @override
  String get cartEmpty => 'カートは空です';

  @override
  String get totalAmount => '合計金額';

  @override
  String get placeOrder => '注文する';

  @override
  String get orderPlaced => '注文が確定されました！';

  @override
  String get orderError => '注文エラー';

  @override
  String get som => 'スム';

  @override
  String get kitchenScreen => 'キッチン画面';

  @override
  String get newOrders => '新しい注文';

  @override
  String get cooking => '調理中';

  @override
  String get ready => '準備完了';

  @override
  String get startCooking => '調理開始';

  @override
  String get markReady => '準備完了にする';

  @override
  String get markServed => '提供済みにする';

  @override
  String get statusPending => '保留中';

  @override
  String get statusCooking => '調理中';

  @override
  String get statusReady => '準備完了';

  @override
  String get statusServed => '提供済み';

  @override
  String get table => 'テーブル';

  @override
  String get welcomeRestaurant => 'レストランへようこそ';

  @override
  String get selectRole => '続けるには役割を選択してください';

  @override
  String get customerMode => 'お客様モード';

  @override
  String get customerSubtitle => 'テーブルから料理を注文する';

  @override
  String get adminPanel => '管理パネル';

  @override
  String get adminSubtitle => 'カテゴリ、メニュー、注文の管理';

  @override
  String get kitchenDisplay => 'キッチン画面';

  @override
  String get kitchenSubtitle => '注文の追跡と調理';

  @override
  String get tableInfo => 'テーブル番号';

  @override
  String get tableOccupiedBadge => 'このテーブルは使用中です';

  @override
  String get orderTracking => '注文追跡';

  @override
  String get all => 'すべて';

  @override
  String error(String msg) {
    return 'エラー: $msg';
  }

  @override
  String get reset => 'リセット';

  @override
  String get restaurantDesc => '美味しい料理、最高のサービス';

  @override
  String get openMenu => 'メニューを開く';

  @override
  String get myOrders => '注文履歴';

  @override
  String get callStaff => 'スタッフを呼ぶ';

  @override
  String get staffCalled => 'スタッフを呼びました！';

  @override
  String get noActiveOrders => 'このテーブルのアクティブな注文はありません。';

  @override
  String get subtotal => '小計';

  @override
  String get requestBill => 'お会計';

  @override
  String get billRequested => 'スタッフに伝票をお知らせしました。';

  @override
  String get statusPreparing => '準備中';

  @override
  String get statusDelivered => '配達済み';

  @override
  String get noOrdersInStage => 'この段階の注文はありません。';

  @override
  String get qrScanTitle => 'QRコードをスキャン';

  @override
  String get qrScanManualTitle => 'QRコードを入力';

  @override
  String get confirm => '確認';

  @override
  String get goBack => '戻る';

  @override
  String get adminLogin => '管理者ログイン';

  @override
  String get adminSignup => '管理者登録';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get createAdminAccount => '新しい管理者アカウントを作成';

  @override
  String get cancelOrder => '注文をキャンセル';

  @override
  String get confirmCancelOrder => 'この注文をキャンセルしますか？';

  @override
  String get enterTableNumber => 'テーブル番号を入力:';

  @override
  String get yes => 'はい、キャンセル';

  @override
  String get no => 'いいえ';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしますか？';

  @override
  String get yesLogout => 'はい、ログアウト';

  @override
  String get ready2 => '完成';

  @override
  String get goToKitchen => 'キッチンへ';

  @override
  String get manageQrCodes => 'QRコード管理';

  @override
  String get editMenu => 'メニュー編集';

  @override
  String get webNoCameraTitle => 'ウェブではカメラは利用できません';

  @override
  String get enterQrManually => 'QRコードを手動で入力してください:';

  @override
  String get cameraNotAvailable => 'このプラットフォームではカメラが利用できません';

  @override
  String get enterQrManuallyShort => 'QRコードのデータを手動で入力してください:';

  @override
  String get adminPanelSubtitle => 'レストラン管理';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get dashboardSubtitle => '本日の統計とリアルタイムデータ';

  @override
  String get todayRevenue => '本日の売上';

  @override
  String get orderCount => '注文数';

  @override
  String get averageOrder => '平均注文額';

  @override
  String get menuItemsCount => 'メニュー品目';

  @override
  String get categoriesLabel => 'カテゴリ';

  @override
  String get topOrdered => '人気ランキング';

  @override
  String get statusCompleted => '完了';

  @override
  String get staffCalls => 'スタッフ呼び出し';

  @override
  String staffCallAtTable(String table) {
    return 'テーブル$table - スタッフ呼び出し';
  }

  @override
  String get markDone => '対応済み';

  @override
  String get staffCallResolved => '呼び出しに対応しました';

  @override
  String get noStaffCalls => '呼び出しはありません';

  @override
  String get staffRequested => 'スタッフを呼んでいます';

  @override
  String get searchOrdersHint => 'テーブルまたは注文IDで検索...';

  @override
  String get noOrdersFound => '注文が見つかりません';

  @override
  String tableNumberLabel(String table) {
    return 'テーブル #$table';
  }

  @override
  String orderNumberLabel(String number) {
    return '注文 #$number';
  }

  @override
  String get kitchenView => 'キッチンビュー';

  @override
  String get qrGenerator => 'QRコード生成';

  @override
  String get menuManagement => 'メニュー管理';

  @override
  String confirmCancelTableOrder(String table) {
    return 'テーブル #$table の注文をキャンセルしますか？';
  }

  @override
  String get sidebarKitchen => 'キッチン';

  @override
  String get ingredients => '食材';

  @override
  String get qrCodes => 'QRコード';

  @override
  String get kitchenOrdersTitle => 'キッチン注文';

  @override
  String get noOrdersAtMoment => '現在注文はありません';

  @override
  String tableWithNumber(String table) {
    return 'テーブル $table';
  }

  @override
  String get generateTableQrCodes => 'テーブルQRコードの作成';

  @override
  String get qrSelectHint =>
      'QRコードを作成するテーブルを選択してください。お客様はテーブルでスマートフォンからQRコードを読み取れます。';

  @override
  String selectedTablesCount(String count) {
    return '選択したテーブル: $count';
  }

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get downloadQrCodes => 'QRコードをダウンロード';

  @override
  String get selectTables => 'テーブルを選択';

  @override
  String get qrCodesReady => 'QRコードの準備完了';

  @override
  String qrGeneratedMessage(String count) {
    return '$count件のテーブルのQRコードを作成しました。\\n\\n次のことができます:\\n- 印刷する\\n- 画面に表示する\\n- お客様に共有する';
  }

  @override
  String get ok => 'OK';
}
