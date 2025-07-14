<!DOCTYPE html>

<html lang="ja">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ログイン画面</title>
    <link rel="stylesheet" type="text/css" href="index.css">

</head>

<body>

<h1>ログイン画面</h1>

<form action="#" method="post">
    <div id="login-container">
        <div id="syainbangou">
            <p class="login-text">社員番号　</p>
            <input type="text" name="userid" id="userid">
        </div>

        <div id="password-container">
            <p class="login-text">パスワード</p>
            <input type="text" name="password" id="password">
        </div>
    </div>

    <div id="button-container">
        <button type="reset">クリア</button>
        <button>ログイン</button>
    </div>
</form>

</body>

</html>