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
  String get cancel => 'キャンセル';

  @override
  String get goToMenu => 'メニューへ';

  @override
  String get checking => '確認中...';

  @override
  String get invalidQr => '無効なQRコードです。もう一度お試しください。';

  @override
  String get searchFood => '料理を検索...';

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
  String get tableInfo => 'テーブル番号';

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
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get cancelOrder => '注文をキャンセル';

  @override
  String get confirmCancelOrder => 'この注文をキャンセルしますか？';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしますか？';

  @override
  String get editMenu => 'メニュー編集';

  @override
  String get cameraNotAvailable => 'このプラットフォームではカメラが利用できません';

  @override
  String get enterQrManuallyShort => 'QRコードのデータを手動で入力してください:';

  @override
  String get adminPanelSubtitle => 'レストラン管理';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get dashboardSubtitle => '直近7日間の注文に基づく集計';

  @override
  String get todayRevenue => '本日の売上（支払い済み）';

  @override
  String get averageOrder => '平均会計額（本日）';

  @override
  String get categoriesLabel => 'カテゴリ';

  @override
  String get topOrdered => '人気ランキング';

  @override
  String get staffCalls => 'スタッフ呼び出し';

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
  String orderNumberLabel(String number) {
    return '注文 #$number';
  }

  @override
  String confirmCancelTableOrder(String table) {
    return 'テーブル #$table の注文をキャンセルしますか？';
  }

  @override
  String get sidebarKitchen => 'キッチン';

  @override
  String get ingredients => '食材';

  @override
  String tableWithNumber(String table) {
    return 'テーブル $table';
  }

  @override
  String get qrSelectHint =>
      'お客様はここに登録されたテーブルでのみ注文できます。QRコードを印刷してテーブルに設置してください。';

  @override
  String get ok => 'OK';

  @override
  String get newIngredient => '食材を追加';

  @override
  String get ingredientsSubtitle => '料理の調理に必要な食材の一覧';

  @override
  String lowStockAlert(String count) {
    return '在庫不足（$count件）';
  }

  @override
  String get lowStock => '在庫不足';

  @override
  String get noIngredientsFound => '食材が見つかりません';

  @override
  String get editAction => '編集';

  @override
  String get deleteAction => '削除';

  @override
  String minQuantityShort(String value) {
    return '最小: $value';
  }

  @override
  String get addIngredientTitle => '食材の新規追加';

  @override
  String get editIngredientTitle => '食材の編集';

  @override
  String get ingredientName => '食材名';

  @override
  String get unitLabel => '単位';

  @override
  String get quantityLabel => '在庫数';

  @override
  String get minimumQuantityLabel => '最小在庫';

  @override
  String get fillAllFields => 'すべての項目を入力してください';

  @override
  String get ingredientAdded => '食材を追加しました';

  @override
  String get ingredientUpdated => '食材を更新しました';

  @override
  String get ingredientDeleted => '食材を削除しました';

  @override
  String get addAction => '追加';

  @override
  String get saveAction => '保存';

  @override
  String get deleteIngredientConfirm => 'この食材を削除しますか？';

  @override
  String get unitPiece => '個';

  @override
  String get unitKg => 'kg';

  @override
  String get unitGram => 'g';

  @override
  String get unitLiter => 'L';

  @override
  String get unitMl => 'mL';

  @override
  String get unitBox => '箱';

  @override
  String get unitPack => 'パック';

  @override
  String get fillRequiredFields => '必須項目をすべて入力してください';

  @override
  String get menuItemAdded => 'メニュー品目を追加しました';

  @override
  String get addNewMenuItem => 'メニュー品目の新規追加';

  @override
  String get itemNameRequired => '品目名 *';

  @override
  String get descriptionLabel => '説明';

  @override
  String get priceRequired => '価格 *';

  @override
  String get categoryRequired => 'カテゴリ *';

  @override
  String get imageUrl => '画像URL';

  @override
  String get addMenuItem => 'メニュー品目を追加';

  @override
  String get menuItems => 'メニュー品目';

  @override
  String get noMenuItemsYet => 'メニュー品目はまだありません';

  @override
  String get deleteItem => '品目の削除';

  @override
  String get confirmDeleteItem => 'この品目を削除しますか？';

  @override
  String get itemDeleted => '品目を削除しました';

  @override
  String get createNewCategory => 'カテゴリの新規作成';

  @override
  String get categoryNameHint => 'カテゴリ名';

  @override
  String get createAction => '作成';

  @override
  String get categoryCreated => 'カテゴリを作成しました';

  @override
  String get enterCategoryName => 'カテゴリ名を入力してください';

  @override
  String torchError(String error) {
    return 'ライトのエラー: $error';
  }

  @override
  String cameraError(String error) {
    return 'カメラのエラー: $error';
  }

  @override
  String get placeQrInFrame => 'QRコードを枠内に合わせてください';

  @override
  String get enterEmailPassword => 'メールアドレスとパスワードを入力してください';

  @override
  String get authUserNotFound => 'このメールアドレスのユーザーが見つかりません';

  @override
  String get authWrongPassword => 'パスワードが正しくありません';

  @override
  String get authInvalidCredential => 'メールアドレスまたはパスワードが正しくありません';

  @override
  String get authNetworkError => 'ネットワーク接続エラー';

  @override
  String get authTooManyRequests => '試行回数が多すぎます。しばらくしてからもう一度お試しください';

  @override
  String get authEmailInUse => 'このメールアドレスは既に登録されています';

  @override
  String get authWeakPassword => 'パスワードが簡単すぎます（6文字以上必要です）';

  @override
  String get authInvalidEmail => 'メールアドレスの形式が正しくありません';

  @override
  String get passwordsMismatch => 'パスワードが一致しません';

  @override
  String get passwordTooShort => 'パスワードは6文字以上にしてください';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get confirmPasswordLabel => 'パスワード（確認）';

  @override
  String get passwordHint => '6文字以上の強力なパスワードを設定してください';

  @override
  String get statusPaid => '支払い済み';

  @override
  String get statusCancelled => 'キャンセル済み';

  @override
  String get retry => '再試行';

  @override
  String get errOrderNotFound => 'この注文は存在しません。';

  @override
  String get errInvalidTransition => '注文のステータスは既に変更されています。最新の状態をご確認ください。';

  @override
  String errItemUnavailable(String name) {
    return '「$name」は現在ご注文いただけません。';
  }

  @override
  String errInsufficientStock(String name) {
    return '在庫が不足しています: $name';
  }

  @override
  String get errBillNotReady => 'テーブルのすべての注文が提供済みになると会計を締められます。';

  @override
  String get errNothingToPay => 'このテーブルに未会計の注文はありません。';

  @override
  String get errTableExists => 'この番号のテーブルは既に登録されています。';

  @override
  String get errCategoryInUse => 'このカテゴリにはまだメニューが登録されています。';

  @override
  String get errPermissionDenied => 'この操作を行う権限がありません。';

  @override
  String get invalidNumber => '正しい数値を入力してください';

  @override
  String get pageNotFound => 'ページが見つかりません';

  @override
  String get accessDenied => 'この画面にアクセスできるスタッフアカウントでログインしてください。';

  @override
  String get staffLogin => 'スタッフログイン';

  @override
  String get staffLoginSubtitle => 'キッチン画面と管理パネル';

  @override
  String get authNoStaffAccess =>
      'このアカウントにはまだスタッフ権限がありません。アクセス申請を送信しました。管理者に承認を依頼してください。';

  @override
  String get requestStaffAccount => 'スタッフアカウントを申請';

  @override
  String get staffRequestSent => 'アカウントを作成しました。管理者の承認後にログインできます。';

  @override
  String get staffSignupHint => 'キッチンスタッフ用のアカウントを作成します。管理者が申請を承認すると利用できます。';

  @override
  String tableNotFound(String table) {
    return 'テーブル$tableは登録されていません。番号をご確認いただくか、スタッフにお尋ねください。';
  }

  @override
  String tableDisabled(String table) {
    return 'テーブル$tableは現在ご注文を受け付けていません。';
  }

  @override
  String get billTotal => 'お会計合計';

  @override
  String get orderCancelled => '注文をキャンセルしました';

  @override
  String get soldOut => '売り切れ';

  @override
  String get bills => '会計';

  @override
  String get noOpenBills => '未会計のテーブルはありません';

  @override
  String get closeBill => '会計を締める（支払い済み）';

  @override
  String confirmCloseBill(String table, String total) {
    return 'テーブル$tableの会計（$total）を支払い済みにしますか？';
  }

  @override
  String billClosed(String table) {
    return 'テーブル$table: 会計を締めました';
  }

  @override
  String get billRequestedByTable => 'お会計の依頼';

  @override
  String get tablesAndQr => 'テーブルとQRコード';

  @override
  String get addTable => 'テーブルを追加';

  @override
  String tableAdded(String table) {
    return 'テーブル$tableを追加しました';
  }

  @override
  String get printQrCodes => 'QRコードを印刷';

  @override
  String get noTablesYet => 'テーブルがまだありません。テーブルを追加するとQRコードが生成されます。';

  @override
  String confirmDeleteTable(String table) {
    return 'テーブル$tableを削除しますか？QRコードは使用できなくなります。';
  }

  @override
  String get tableStatusDisabled => '無効';

  @override
  String get tableStatusFree => '空席';

  @override
  String get staffSection => 'スタッフ';

  @override
  String get staffAdminHint =>
      'キッチンスタッフはログイン画面からアカウントを作成します。ここで申請を承認すると、注文と在庫にアクセスできるようになります。';

  @override
  String get staffRequestsTitle => 'アクセス申請';

  @override
  String get noStaffRequests => '保留中の申請はありません';

  @override
  String get approveAction => '承認';

  @override
  String get rejectAction => '却下';

  @override
  String staffApproved(String email) {
    return '$email にキッチン権限を付与しました';
  }

  @override
  String get kitchenStaffTitle => 'キッチンスタッフ';

  @override
  String get noKitchenStaff => 'キッチンスタッフはまだいません';

  @override
  String get revokeAction => '権限を取り消す';

  @override
  String confirmRevokeStaff(String email) {
    return '$email のキッチン権限を取り消しますか？';
  }

  @override
  String confirmDeleteCategory(String name) {
    return 'カテゴリ「$name」を削除しますか？';
  }

  @override
  String get createCategoryFirst => '先にカテゴリを作成してください。';

  @override
  String get menuItemUpdated => 'メニューを更新しました';

  @override
  String recipeLinesCount(String count) {
    return 'レシピ: 食材$count件';
  }

  @override
  String get availableOnMenu => 'メニューに表示';

  @override
  String get recipeTitle => 'レシピ（1人前）';

  @override
  String get recipeHint => 'キッチンが注文を受け付けると、この数量が在庫から差し引かれます。';

  @override
  String get addRecipeLine => '食材を追加';

  @override
  String get weekRevenue => '今週の売上';

  @override
  String get todayOrdersCount => '本日の注文数';

  @override
  String get weekOrdersCount => '今週の注文数';

  @override
  String get openOrdersCount => '未会計の注文';

  @override
  String get cancelledToday => '本日のキャンセル';

  @override
  String get tableStatusOccupied => '使用中';
}
