<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/logs-selector.css">
    <title>ログセレクター</title>
</head>
<body>
<h2>どちらのログを確認しますか</h2>

<div id="buttons-holder">

    <form action="logs.jsp" method="post">
        <input type="hidden" id="activityType" name="activityType" value="">
    </form>

    <button type="button" class="normal-button">商品</button>
    <button type="button" class="normal-button">売上</button>
    <button type="button" class="normal-button">人事</button>
    <button type="button" class="normal-button">お知らせ</button>
    <button type="button" class="normal-button">すべて</button>
</div>

<script>
    buttons = Array.from(document.getElementsByTagName("button"));
    activityType = document.getElementById("activityType");
    buttons.forEach(button => {
        button.addEventListener("click", () => {
            activityType.value = button.innerHTML;
            document.forms[0].submit();
        })
    });
</script>
</body>
</html>