// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get menu => 'メニュー';
  @override
  String get cart => 'カート';
  @override
  String get orders => '注文';
  @override
  String get chooseLanguage => '言語を選択してください';
  @override
  String get tableEntry => 'テーブル選択';
  @override
  String get scanQr => 'QRコードをスキャン';
  @override
  String get enterTableManually => 'テーブル番号を入力';
  @override
  String get searchFood => '料理を検索...';
  @override
  String get addToCart => 'カートに追加';
  @override
  String get orderNow => '注文する';
  @override
  String get total => '合計';
  @override
  String get statusPending => '待機中';
  @override
  String get statusCooking => '調理中';
  @override
  String get statusReady => '準備完了';
  @override
  String get statusServed => '提供済み';
  @override
  String get adminDashboard => '管理者ダッシュボード';
  @override
  String get kitchenOrders => 'キッチン注文';

  @override
  String get restaurantName => 'ユニバーサルレストラン';
  @override
  String get restaurantDesc => '美味しい料理、最高のサービス';
  @override
  String get tableNumber => 'テーブル番号';
  @override
  String get tableOccupied => 'このテーブルは使用中です';
  @override
  String get reset => 'リセット';
  @override
  String get openMenu => 'メニューを開く';
  @override
  String get myOrders => '私の注文';
  @override
  String get callStaff => 'スタッフを呼ぶ';
  @override
  String get staffCalled => 'スタッフを呼びました！';

  @override
  String get welcome => 'ようこそ！';
  @override
  String get enterTableOrScan => 'テーブル番号を入力するか、テーブルのQRコードをスキャンしてください。';
  @override
  String get tableNumberLabel => 'テーブル番号';
  @override
  String get tableNumberHint => '1, 2, 3...';
  @override
  String get goToMenu => 'メニューへ';
  @override
  String get checking => '確認中...';
  @override
  String get scanQrTitle => 'QRコードをスキャン';
  @override
  String get scanQrDescription => 'カメラを使用してテーブルのQRコードをスキャンします';
  @override
  String get cancel => 'キャンセル';
  @override
  String get openCamera => 'カメラを開く';
  @override
  String get enterTableNumber => 'テーブル番号を入力';
  @override
  String get tableNumberMustBeNumber => 'テーブル番号は数字でなければなりません';
  @override
  String get tableOccupiedTitle => 'テーブル使用中';
  @override
  String get tableOccupiedMessage => 'このテーブルは現在使用中です。続行しますか？';
  @override
  String get continueText => '続行';
  @override
  String get invalidQrCode => '無効なQRコード。もう一度お試しください。';
  @override
  String qrScannedTable(String tableNum) => 'QRスキャン完了: テーブル $tableNum';
  @override
  String errorMessage(String message) => 'エラー: $message';

  @override
  String get all => 'すべて';
  @override
  String get noItemsFound => '商品が見つかりません。';
  @override
  String itemAdded(String item) => '$item を追加しました！';
  @override
  String get currency => 'ソム';

  @override
  String get yourCart => 'カート';
  @override
  String get cartEmpty => 'カートは空です';
  @override
  String get totalAmount => '合計金額';
  @override
  String get confirmOrder => '注文を確定';

  @override
  String tableOrders(String tableId) => 'テーブル $tableId - 注文';
  @override
  String get noActiveOrders => 'このテーブルにはアクティブな注文がありません。';
  @override
  String get subtotal => '小計';
  @override
  String get waitressNotified => 'お会計をお知らせしました。';
  @override
  String get requestBill => 'お会計';
  @override
  String get preparing => '準備中';
  @override
  String get ready => '準備完了';
  @override
  String get delivered => '提供済み';

  @override
  String get kitchenScreen => 'キッチン画面';
  @override
  String get newOrders => '新規注文';
  @override
  String get cooking => '調理中';
  @override
  String get startCooking => '調理開始';
  @override
  String get markAsReady => '準備完了にする';
  @override
  String get markAsServed => '提供済みにする';
  @override
  String get noOrdersInStage => 'この段階の注文はありません。';
  @override
  String get items => '品';

  @override
  String get menuManagement => 'メニュー管理';
  @override
  String get cancelOrderByTable => 'テーブルの注文をキャンセル';
  @override
  String get staffCalls => 'スタッフ呼び出し';
  @override
  String get activeOrders => 'アクティブな注文';
  @override
  String get noOrdersYet => 'まだ注文がありません';
  @override
  String get enterTableNumberColon => 'テーブル番号を入力:';
  @override
  String get cancelOrderBtn => '注文をキャンセル';
  @override
  String tableOrderCancelled(String tableNum) => 'テーブル #$tableNum の注文がキャンセルされました';
  @override
  String get noActiveOrderForTable => 'このテーブルにはアクティブな注文がありません';
  @override
  String get staffCallResolved => 'スタッフ呼び出し対応済み';
  @override
  String get orderCancelled => '注文がキャンセルされました';
  @override
  String get confirmTitle => '確認';
  @override
  String cancelOrderForTable(String tableNumber) => 'テーブル #$tableNumber の注文をキャンセルしますか？';
  @override
  String get no => 'いいえ';
  @override
  String get yesCancel => 'はい、キャンセル';
  @override
  String get categories => 'カテゴリー';
  @override
  String get menuItems => 'メニュー商品';
  @override
  String get system => 'システム';
  @override
  String get live => '稼働中';
  @override
  String get resolve => '対応済み';
  @override
  String calledAt(String time) => '呼び出し: $time';
  @override
  String get tableLabel => 'テーブル';

  @override
  String get adminLogin => '管理者ログイン';
  @override
  String get emailAndPasswordRequired => 'メールアドレスとパスワードを入力してください';
  @override
  String get email => 'メール';
  @override
  String get emailHint => 'admin@gmail.com';
  @override
  String get password => 'パスワード';
  @override
  String get login => 'ログイン';
  @override
  String get createNewAdmin => '新しい管理者アカウントを作成';
  @override
  String get debugFirebase => 'デバッグ - Firebase状態';
  @override
  String get noAdminRights => '管理者権限がありません。';
  @override
  String get userNotFound => 'このメールアドレスのユーザーが見つかりません';
  @override
  String get wrongPassword => 'パスワードが間違っています';
  @override
  String get invalidCredential => 'メールアドレスまたはパスワードが間違っています';
  @override
  String get networkError => 'ネットワーク接続エラー';
  @override
  String get tooManyRequests => '試行回数が多すぎます。後でもう一度お試しください';

  @override
  String get welcomeToApp => 'レストランアプリへようこそ';
  @override
  String get selectRoleToContinue => '続行するには役割を選択してください';
  @override
  String get customerMode => 'お客様モード';
  @override
  String get customerSubtitle => 'テーブルから美味しい料理を注文';
  @override
  String get adminPanel => '管理者パネル';
  @override
  String get adminSubtitle => 'カテゴリー、メニュー、注文を管理';
  @override
  String get kitchenDisplay => 'キッチンディスプレイ';
  @override
  String get kitchenSubtitle => '新規注文と調理中の注文を追跡';

  @override
  String get selectLanguage => '言語を選択';
  @override
  String get selectLanguageSubtitle => 'ご希望の言語を選択してください';
  @override
  String deviceLanguage(String language) => 'デバイスの言語: $language';
  @override
  String get failedToSaveLanguage => '言語設定の保存に失敗しました';
  @override
  String get errorSelectingLanguage => '言語の選択でエラーが発生しました';
}
