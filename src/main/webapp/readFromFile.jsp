<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%

	//session stuff

    //文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>ファイルから読み込む</title>
	<link rel="stylesheet" type="text/css" href="css/readFromFile.css">
</head>
<body>

	<div id="everything-wrapper">
		<h2>売上データをファイルから読み込む</h2>

		<form action="sales-register.jsp" method="post" enctype="multipart/form-data">

			<p id="read-file-intro">対象のファイルを選択してください。</p>
			<input type="file" id="fileInput" name="fileInput" accept="text/csv" required>

			<div id="inputs-holder">
				<div class="input-holder">
					<input type="radio" name="targetDate" value="today" checked>本日のデータのみ読み込む
				</div>
				<div class="input-holder">
					<input type="radio" name="targetDate" value="yesterday">昨日のデータのみ読み込む
				</div>
				<div id="adjust-date-holder">
					<div class="input-holder">
						<input type="radio" name="targetDate" value="adjust" id="adjust">日付を指定する
					</div>
					<input type="date" name="readFileAdjustDate" id="readFileAdjustDate">
				</div>
				<div class="input-holder">
					<input type="radio" name="targetDate" value="all">ファイルを全体的に読み込む
				</div>
			</div>

			<input type="hidden" name="registerType" value="fromCSV">

			<div id="buttons-holder">
				<button class="normal-button" type="button" id="cancelButton">キャンセル</button>
				<button class="normal-button">読み込む</button>
			</div>

		</form>

		<%-- キャンセルの非表示フォーム--%>
		<form action="sales.jsp" method="post" id="returnForm">

		</form>

	</div>

	<script>
		Array.from(document.getElementsByName("targetDate")).forEach(element => element.addEventListener("input", toggleAdjustDate));
		document.getElementById("cancelButton").addEventListener("click", () => {
			document.getElementById("returnForm").submit();
		});

		function toggleAdjustDate(){
			let dateInput = document.getElementById("readFileAdjustDate");
			if(this.value == "adjust"){
				dateInput.style.display = "flex";
			} else {
				dateInput.style.display = "none";
			}
		}
	</script>

</body>
</html>
