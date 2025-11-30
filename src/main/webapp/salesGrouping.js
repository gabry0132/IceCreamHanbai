//売上データにかかわるすべての集計処理をここでまとめる

//集計オプション：表示/非表示の切り替え設定
let isGroupingDivOpen = false;
const groupingToggleButton = document.getElementById("grouping-toggle-button");
const groupingToggleButtonImage = document.getElementById("grouping-toggle-button-image");

const groupingSettingsDiv = document.getElementById("groupingSettingsDiv");
const groupingResultsDiv = document.getElementById("groupingResultsDiv");
const groupingResultIntro = document.getElementById("groupingResultsIntro");

groupingToggleButton.addEventListener("click", () => {
    if(isGroupingDivOpen) {
        groupingDiv.style.height = "0px";
        groupingDiv.style.margin = "0px";
        groupingToggleButtonImage.style.transform = "rotate(0deg)";
        isGroupingDivOpen = false;
    } else {
        groupingDiv.style.height = "400px";     
        groupingDiv.style.margin = "auto auto 50px auto";
        groupingToggleButtonImage.style.transform = "rotate(180deg)";
        isGroupingDivOpen = true;
    }
})

//期間検索（詳細指定ではない）年の初期設定
let allYearsSelects = Array.from(document.getElementsByClassName("recentYearsSelect"));
const date = new Date();
const currentYear = date.getFullYear();
let howManyYearsToConsider = 2;
let str = "";
allYearsSelects.forEach(select => {
    str = "";
    for (let j = currentYear - howManyYearsToConsider; j <= currentYear; j++) {
        str+=`<option value="${j}"`
        if(j === currentYear) str+=" selected";
        str+=`>${j}</option>\n`
    }
    select.innerHTML += str;
})

    
//期間検索（詳細指定ではない）月の初期設定
let allMonthsSelects = Array.from(document.getElementsByClassName("allMonthsSelect"));
const currentMonth = date.getMonth() + 1;
allMonthsSelects.forEach(select => {
    str = "";
    for (let j = 1; j <= 12; j++) {
        str+=`<option value="${j}"`
        if(j === currentMonth) str+=" selected";
        str+=`>${j}</option>`
    }
    select.innerHTML += str;
})

//期間 トップ&ワースト10　詳細指定（詳細入力）チェックボックスの動作 + 初期trigger (dispatchEvent)
//トップ10
const periodTopTenDetailedCheckbox = document.getElementById("periodTopTen-DetailedCheckbox");
periodTopTenDetailedCheckbox.addEventListener("change", () => {
    if(periodTopTenDetailedCheckbox.checked){
        document.getElementById("periodTopTen-NONDetailedSearchParams").style.display = "none";
        document.getElementById("periodTopTen-DetailedSearchParams").style.display = "flex";
    } else {
        document.getElementById("periodTopTen-NONDetailedSearchParams").style.display = "flex";
        document.getElementById("periodTopTen-DetailedSearchParams").style.display = "none";
    }
})
periodTopTenDetailedCheckbox.dispatchEvent(new Event("change"));
//ワースト10
const periodWorstTenDetailedCheckbox = document.getElementById("periodWorstTen-DetailedCheckbox");
periodWorstTenDetailedCheckbox.addEventListener("change", () => {
    if(periodWorstTenDetailedCheckbox.checked){
        document.getElementById("periodWorstTen-NONDetailedSearchParams").style.display = "none";
        document.getElementById("periodWorstTen-DetailedSearchParams").style.display = "flex";
    } else {
        document.getElementById("periodWorstTen-NONDetailedSearchParams").style.display = "flex";
        document.getElementById("periodWorstTen-DetailedSearchParams").style.display = "none";
    }
})
periodWorstTenDetailedCheckbox.dispatchEvent(new Event("change"));

/* ******************* */
//実際のデータ取得と表示
/* ******************* */

//全体的 TOP
document.getElementById("topTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "全体的 TOP";
    let topTotItemLimit = document.getElementById("topTotItemLimit").value;
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})

//全体的 WORST
document.getElementById("worstTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "全体的 WORST";
    let worstTotItemLimit = document.getElementById("worstTotItemLimit").value;
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + worstTotItemLimit + "&worstFlag=true";
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})

//年 TOP10
document.getElementById("yearTopTen-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let yearTopTen = document.getElementById("yearTopTen").value;
    let rankingType = yearTopTen + "年 TOP";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&yearFrom=" + yearTopTen;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})

//年 WORST10
document.getElementById("yearWorstTen-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let yearWorstTen = document.getElementById("yearWorstTen").value;
    let rankingType = yearWorstTen + "年 WORST";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&yearFrom=" + yearWorstTen + "&worstFlag=true";
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})

//期間 TOP10
document.getElementById("periodTopTen-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let yearFrom = "";
    let yearTo = "";
    let monthFrom = "";
    let monthTo = "";
    let dayFrom = "";
    let dayTo = "";

    let rankingType = "期間年 TOP";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType;

    let detailedCheckbox = document.getElementById("periodTopTen-DetailedCheckbox");
    if(detailedCheckbox.checked) {
        dateFrom = document.getElementById("periodTopTen-startDate").value;
        dateTo = document.getElementById("periodTopTen-endDate").value;

        //2025-10-15の形で来ます
        yearFrom = dateFrom.split("-")[0];
        yearTo = dateTo.split("-")[0];
        monthFrom = dateFrom.split("-")[1];
        monthTo = dateTo.split("-")[1];
        dayFrom = dateFrom.split("-")[2];
        dayTo = dateTo.split("-")[2];
        url += "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom;
        url += "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo;
    } else {
        yearFrom = document.getElementById("periodTopTen-year").value;
        monthFrom = document.getElementById("periodTopTen-month").value;
        url += "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom;
    }

    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})

//期間 WORST10
document.getElementById("periodWorstTen-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let yearFrom = "";
    let yearTo = "";
    let monthFrom = "";
    let monthTo = "";
    let dayFrom = "";
    let dayTo = "";

    let rankingType = "期間年 TOP";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType;

    let detailedCheckbox = document.getElementById("periodWorstTen-DetailedCheckbox");
    if(detailedCheckbox.checked) {
        dateFrom = document.getElementById("periodWorstTen-startDate").value;
        dateTo = document.getElementById("periodWorstTen-endDate").value;

        //2025-10-15の形で来ます
        yearFrom = dateFrom.split("-")[0];
        yearTo = dateTo.split("-")[0];
        monthFrom = dateFrom.split("-")[1];
        monthTo = dateTo.split("-")[1];
        dayFrom = dateFrom.split("-")[2];
        dayTo = dateTo.split("-")[2];
        url += "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom;
        url += "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo + "&worstFlag=true";
    } else {
        yearFrom = document.getElementById("periodWorstTen-year").value;
        monthFrom = document.getElementById("periodWorstTen-month").value;
        url += "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&worstFlag=true";
    }

    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json));
})


/* ******************* */
//canvasでデータを表示する
/* ******************* */
let chart = null;

function drawRankingGraph(json){
    clearCanvas();

    if(json.data.length === 0){
        document.getElementById("groupingResultPlaceholder").innerHTML = "データがありません。";
        return;
    }

    try {
        let xValues = [];
        let yValues = [];
        let barColors = [];
        json.data.forEach(product => {
            xValues.push(product.name);
            yValues.push(product.totalSales);
            barColors.push(getRandomHSLColor())
        });

        chart = new Chart("resultChart", {
            type: "bar",
            data: {
                labels: xValues,
                datasets: [{
                    label: "売上ランキング",
                    backgroundColor: barColors,
                    data: yValues
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: json.title
                    }
                }
            }
        });
    } catch (error) {
        console.log("failed to generate chart", error);
        document.getElementById("groupingResultPlaceholder").innerHTML = "エラーが発生しました。<br>" + error.message
    }
    
}

function getRandomHSLColor(){
    const h = Math.floor(Math.random() * 360);
    const s = 70;
    const l = 60;
    return `hsl(${h}, ${s}%, ${l}%)`;
}

function clearCanvas(){
    document.getElementById("groupingResultPlaceholder").innerHTML = "";
    if(chart) chart.destroy();
}

function showLoadingMessage(){
    document.getElementById("groupingResultPlaceholder").innerHTML = "読み込み中...";
}