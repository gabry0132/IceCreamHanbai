//売上データにかかわるすべての集計処理をここでまとめる

//集計オプション：表示/非表示の切り替え設定
let isGroupingDivOpen = false;
const groupingToggleButton = document.getElementById("grouping-toggle-button");
const fullScreenCanvasButtonHolder = document.getElementById("fullScreenCanvasButtonHolder");
const groupingToggleButtonImage = document.getElementById("grouping-toggle-button-image");

const groupingSettingsDiv = document.getElementById("groupingSettingsDiv");
const groupingResultsDiv = document.getElementById("groupingResultsDiv");
const groupingResultIntro = document.getElementById("groupingResultsIntro");

//集計div全体の表示/非表示設定
groupingToggleButton.addEventListener("click", () => {
    if(isGroupingDivOpen) {
        groupingDiv.style.height = "0px";
        groupingDiv.style.margin = "0px";
        groupingDiv.style.border = "none";
        groupingToggleButtonImage.style.transform = "rotate(0deg)";
        clearCanvas();
        document.getElementById("groupingResultPlaceholder").innerHTML = "集計オプションを選んでください";
        isGroupingDivOpen = false;
    } else {
        groupingDiv.style.height = "420px";
        groupingDiv.style.margin = "auto auto 50px auto";
        groupingDiv.style.border = "1px solid black";
        groupingToggleButtonImage.style.transform = "rotate(180deg)";
        isGroupingDivOpen = true;
    }
})

//canvasのfullscreenボタンを押した時の切り替え
fullScreenCanvasButtonHolder.addEventListener("click", () => {
    if(useFullscreenCanvas) return;
    openFullscreenCanvasPopup();
    runLatestChartQuery();
})

//canvasのfullscreenポップアップを解除する
document.getElementById("black-background").addEventListener("click", closeFullscreenCanvasPopup);
document.getElementById("closeFullScreenCanvas").addEventListener("click", closeFullscreenCanvasPopup);

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

//販売動向：商品を選択したら他のドロップダウンメニューから選択できないようにする
const productToBeComparedSelects = Array.from(document.getElementsByClassName("productToBeComparedSelect"));
productToBeComparedSelects.forEach(select => {
    select.addEventListener("change", (e) => {
        let element = e.target;
        let currentlyChosenValues = [];
        productToBeComparedSelects.forEach(selectElement => {
            if(selectElement.value != null || selectElement.value != undefined){
                currentlyChosenValues.push(selectElement.value);
            }
        })
        productToBeComparedSelects.forEach(selectElement => {
            if(selectElement.id !== element.id){
                let options = Array.from(selectElement.children);
                options.forEach(option => {
                    if(currentlyChosenValues.includes(option.value)){
                        option.setAttribute("hidden","true");
                    } else {
                        option.removeAttribute("hidden")
                    }
                })
            }
        })
    })
})

//販売動向：クリアボタンの操作
document.getElementById("clear-compare-btn").addEventListener("click", () => {
    productToBeComparedSelects.forEach(select => {
        let options = Array.from(select.children);
        options.forEach(option => {
            if(option.value != null || options.value != undefined){
                option.removeAttribute("hidden")
            }
        })
        select.selectedIndex = 0;
    })
})


/* ******************* */
//実際のデータ取得と表示
/* ******************* */

//今日の TOP
document.getElementById("dailyTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "今日の TOP";
    let topTotItemLimit = "unlimited";
    let calculationMode = "sales";
    let dailyTotCalculationModeInputs = Array.from(document.getElementsByName("dailyTotCalculationMode"));
    dailyTotCalculationModeInputs.forEach(input => {
        if(input.checked) calculationMode = input.value;
        return;
    })

    let date = new Date();
    let yearFrom = date.getFullYear();
    let yearTo = yearFrom;
    let monthFrom = date.getMonth() + 1;
    let monthTo = monthFrom;
    let dayFrom = date.getDate();
    let dayTo = dayFrom;

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit +"&calculationMode=" + calculationMode +
     "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom +
     "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json, calculationMode, "一般集計"));
})

//今週の TOP
document.getElementById("weeklyTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "今週の TOP";
    let topTotItemLimit = "unlimited";
    let calculationMode = "sales";
    let dailyTotCalculationModeInputs = Array.from(document.getElementsByName("weeklyTotCalculationMode"));
    dailyTotCalculationModeInputs.forEach(input => {
        if(input.checked) calculationMode = input.value;
        return;
    })

    let date = new Date();

    let yearFrom = date.getFullYear();
    let yearTo = yearFrom;
    let monthFrom = date.getMonth() + 1;
    let monthTo = monthFrom;
    let dayFrom = date.getDate();
    let dayTo = dayFrom;

    if(date.getDay() <= 6){
        dayFrom = 1;
    } else {
        for (let i = date.getDay(); i > 0; i--) {
            dayFrom--;
        }
    }
    let lastDayUtilArray = [
        //うるう年かどうかチェックする
        {lastDay:returnLastDayOfFebruary(), months:[2]},
        {lastDay:30, months:[4,6,9,11]},
        {lastDay:31, months:[1,3,5,7,8,10,12]}
    ]
    let doBreak = false;
    for (let i = date.getDay(); i < 6; i++) {
        if(doBreak) break;
        if(dayTo >= 28){
            lastDayUtilArray.forEach(util => {
                if(util.months.includes(monthTo)){
                    dayTo = util.lastDay;
                    doBreak = true;
                    return;
                }
            })
        }
        dayTo++;
    }

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit +"&calculationMode=" + calculationMode +
     "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom +
     "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json, calculationMode, "一般集計"));
})

//今月の TOP
document.getElementById("monthlyTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "今月の TOP";
    let topTotItemLimit = "unlimited";
    let calculationMode = "sales";
    let dailyTotCalculationModeInputs = Array.from(document.getElementsByName("monthlyTotCalculationMode"));
    dailyTotCalculationModeInputs.forEach(input => {
        if(input.checked) calculationMode = input.value;
        return;
    })

    let date = new Date();

    let yearFrom = date.getFullYear();
    let yearTo = yearFrom;
    let monthFrom = date.getMonth() + 1;
    let monthTo = monthFrom;
    let dayFrom = 1;
    let dayTo = 31;
    
    let lastDayUtilArray = [
        //うるう年かどうかチェックする
        {lastDay:returnLastDayOfFebruary(), months:[2]},
        {lastDay:30, months:[4,6,9,11]},
        {lastDay:31, months:[1,3,5,7,8,10,12]}
    ];
    lastDayUtilArray.forEach(util => {
        if(util.months.includes(monthTo)){
            dayTo = util.lastDay;
            return;
        }
    })

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit +"&calculationMode=" + calculationMode +
     "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom +
     "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json, calculationMode, "一般集計"));
})

//今年の TOP
document.getElementById("yearlyTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "今年の TOP";
    let topTotItemLimit = "unlimited";
    let calculationMode = "sales";
    let dailyTotCalculationModeInputs = Array.from(document.getElementsByName("yearlyTotCalculationMode"));
    dailyTotCalculationModeInputs.forEach(input => {
        if(input.checked) calculationMode = input.value;
        return;
    })

    let date = new Date();

    let yearFrom = date.getFullYear();
    let yearTo = yearFrom;
    let monthFrom = 1;
    let monthTo = 12;
    let dayFrom = 1;
    let dayTo = 31;

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit +"&calculationMode=" + calculationMode +
     "&yearFrom=" + yearFrom + "&monthFrom=" + monthFrom + "&dayFrom=" + dayFrom +
     "&yearTo=" + yearTo + "&monthTo=" + monthTo + "&dayTo=" + dayTo;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json, calculationMode, "一般集計"));
})

//全体的 TOP
document.getElementById("topTot-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let rankingType = "全体的 TOP";
    let topTotItemLimit = document.getElementById("topTotItemLimit").value;
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getRanking?rankingType=" + rankingType +
     "&rankingItemLimit=" + topTotItemLimit;
    fetch(url)
          .then(res => res.json())
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
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
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
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
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
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
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
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
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
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

    let rankingType = "期間年 WORST";
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
          .then(json => drawRankingGraph(json, "sales", "売上ランキング"));
})

//売上高構成比較チャート：売上個数
document.getElementById("percentageSales-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let targetYear = document.getElementById("percentageSalesYear").value;
    let rankingType = targetYear + "年 売上高構成比較チャート:売上個数";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getPercentPie?rankingType=" + rankingType +
     "&targetYear=" + targetYear;
    fetch(url)
          .then(res => res.json())
          .then(json => drawPercentPieGraph(json, "sales"));
})

//売上高構成比較チャート：利益
document.getElementById("percentageProfits-btn").addEventListener("click", () =>{
    showLoadingMessage();
    let targetYear = document.getElementById("percentageProfitsYear").value;
    let rankingType = targetYear + "年 売上高構成比較チャート:利益";
    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getPercentPie?rankingType=" + rankingType +
     "&targetYear=" + targetYear;
    fetch(url)
          .then(res => res.json())
          .then(json => drawPercentPieGraph(json, "profits"));
})

//全体確認・売上個数 (all products, General)
document.getElementById("compareGeneral-btn").addEventListener("click", () =>{
    
    showLoadingMessage();

    let rankingType = "全体動向";
    let monthsInterval = 6;
    let compareGeneralTimeFrameInputs = Array.from(document.getElementsByName("compareGeneralTimeFrame"));
    compareGeneralTimeFrameInputs.forEach(input => {
        if(input.checked) monthsInterval = input.value;
        return;
    })

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getSalesTrend?rankingType=" + rankingType +
     "&monthsInterval=" + monthsInterval;

    fetch(url)
          .then(res => res.json())
          .then(json => drawSalesBarGraph(json, "sales"));
})

//全体確認・利益 (all products, Profits)
document.getElementById("compareGeneralSales-btn").addEventListener("click", () =>{
    
    showLoadingMessage();

    let rankingType = "全体動向";
    let monthsInterval = 6;
    let compareGeneralSalesTimeFrameInputs = Array.from(document.getElementsByName("compareGeneralSalesTimeFrame"));
    compareGeneralSalesTimeFrameInputs.forEach(input => {
        if(input.checked) monthsInterval = input.value;
        return;
    })

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getSalesTrend?rankingType=" + rankingType +
     "&monthsInterval=" + monthsInterval;

    fetch(url)
          .then(res => res.json())
          .then(json => drawSalesBarGraph(json, "profits"));
})

//動向確認・比較 (sales trends)
document.getElementById("compare-btn").addEventListener("click", () =>{
    //入力チェック
    let selectedValues = [];
    productToBeComparedSelects.forEach(select => {
        if(select.value !== undefined && select.value !== null && select.value !== ""){
            selectedValues.push(select.value);
        }
    })
    if(selectedValues.length === 0){
        document.getElementById("productToBeCompared1").focus({ focusVisible: true });
        return;
    }
    
    showLoadingMessage();

    let rankingType = "販売動向";
    let monthsInterval = 6;
    let compareTimeFrameInputs = Array.from(document.getElementsByName("compareTimeFrame"));
    compareTimeFrameInputs.forEach(input => {
        if(input.checked) monthsInterval = input.value;
        return;
    })

    let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getSalesTrend?rankingType=" + rankingType +
     "&monthsInterval=" + monthsInterval;
    for (let i = 0; i < selectedValues.length; i++) {
        url += "&product" + (i + 1) + "=" + selectedValues[i];
    }

    fetch(url)
          .then(res => res.json())
          .then(json => drawTrendsGraph(json));
})

/* ******************* */
//canvasでデータを表示する
/* ******************* */
let chart = null;
let useFullscreenCanvas = false;
let targetCanvasID = "";
setTargetCanvasID();
let latestChartQuery = {
    funct: null,
    params: []
}

function drawRankingGraph(json, calculationMode, datasetLabel){
    clearCanvas();

    if(json.data.length === 0){
        document.getElementById("groupingResultPlaceholder").innerHTML = "データがありません。";
        return;
    }

    showFullscreenCanvasButton();
    updateLatestChartQuery(drawRankingGraph,[json, calculationMode, datasetLabel]);

    try {
        let xValues = [];
        let yValues = [];
        let barColors = [];
        json.data.forEach(product => {
            if(calculationMode === "sales") {
                xValues.push(product.name);
                yValues.push(product.totalSales);
            } else if(calculationMode === "profits") {
                xValues.push(product.name + "（" + product.totalProfit + "円）");
                yValues.push(product.totalProfit);
            }
            barColors.push(getRandomHSLColor())
        });

        chart = new Chart(targetCanvasID, {
            type: "bar",
            data: {
                labels: xValues,
                datasets: [{
                    label: datasetLabel,
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

function drawPercentPieGraph(json, calculationMode){
    clearCanvas();

    if(json.data.length === 0){
        document.getElementById("groupingResultPlaceholder").innerHTML = "データがありません。";
        return;
    }

    showFullscreenCanvasButton();
    updateLatestChartQuery(drawPercentPieGraph,[json, calculationMode]);

    //pieチャートだけをmargin:autoにする
    setPieChartsMarginAuto();

    let total = 0;
    json.data.forEach(product => {
        
        if(calculationMode === "sales") total += product.quantity;
        else if(calculationMode === "profits") total += (product.quantity * product.price) - (product.quantity * product.purchaseCost);

    })

    let xValues = [];
    let yValues = [];
    let barColors = [];
    let profitCurrent = 0;
    json.data.forEach(product => {
        profitCurrent = (product.quantity * product.price) - (product.quantity * product.purchaseCost);
        //パーセントを求める
        if(calculationMode === "sales"){
            xValues.push(product.name + "（" + product.quantity + "個）");
            yValues.push(product.quantity * 100 / total);
        } else if(calculationMode === "profits"){
            xValues.push(product.name + " ("+ profitCurrent +"円)");
            yValues.push(profitCurrent * 100 / total);
        }
        barColors.push(getRandomHSLColor());
    });

    try {
        chart = new Chart(targetCanvasID, {
            type: "pie",
            data: {
                labels: xValues,
                datasets: [{
                    backgroundColor: barColors,
                    data: yValues
                }]
            },
            options: {
                plugins:{
                    title: {
                        display: true,
                        text: json.title
                    },
                     legend: {
                        position: "right",  // move to the right
                        align: "center",    // vertical center (optional)
                        labels: {
                            padding: 20,    // spacing between items
                            boxWidth: 20,   // size of color squares
                            usePointStyle: false
                        }
                    }
                }
            }
        });
    } catch (error) {
        console.log("failed to generate chart", error);
        document.getElementById("groupingResultPlaceholder").innerHTML = "エラーが発生しました。<br>" + error.message;
    }
}

function drawSalesBarGraph(json, calculationMode){
    clearCanvas();

    if(json.data.length === 0){
        document.getElementById("groupingResultPlaceholder").innerHTML = "データがありません。";
        return;
    }

    showFullscreenCanvasButton();
    updateLatestChartQuery(drawSalesBarGraph,[json, calculationMode]);

    let xValues = [];
    let yValues = [];
    let barColors = [];

    json.data.forEach(product => {
        let productProfit = (product.price * product.monthlySales) - (product.purchaseCost * product.monthlySales);
        if(calculationMode === "sales"){    
            if (xValues.includes(product.yearMonth)){
                yValues[xValues.lastIndexOf(product.yearMonth)] += product.monthlySales;
            } else {
                xValues.push(product.yearMonth);
                yValues.push(product.monthlySales);
            }
        } else if(calculationMode === "profits"){    
            if (xValues.includes(product.yearMonth)){
                yValues[xValues.lastIndexOf(product.yearMonth)] += productProfit;
            } else {
                xValues.push(product.yearMonth);
                yValues.push(productProfit);
            }
        }
        barColors.push(getRandomHSLColor());
    });

    if(xValues.length != yValues.length){
        console.log("failed to generate bar chart");
        document.getElementById("groupingResultPlaceholder").innerHTML = "エラーが発生しました。";
        return;
    }

    //利益の場合は利益をラベルに付けます（前のループ内に分岐条件なのでできません）
    if(calculationMode === "profits"){
        for (let i = 0; i < xValues.length; i++) {
            xValues[i] += "（" + yValues[i] + "円）";
        }
    }

    try {
        chart = new Chart(targetCanvasID, {
        type: "bar",
        data: {
            labels: xValues,
            datasets: [{
                label: json.monthsInterval + "ヶ月間",
                backgroundColor: barColors,
                data: yValues
            }]
        },
        options: {
                plugins:{
                    title: {
                        display: true,
                        text: json.title
                    }
                }
            }
        });
    } catch (error) {
        console.log("failed to generate chart", error);
        document.getElementById("groupingResultPlaceholder").innerHTML = "エラーが発生しました。<br>" + error.message;

    }
}

function drawTrendsGraph(json){
    clearCanvas();

    if(json.data.length === 0){
        document.getElementById("groupingResultPlaceholder").innerHTML = "データがありません。";
        return;
    }

    showFullscreenCanvasButton();
    updateLatestChartQuery(drawTrendsGraph,[json]);

    let products = [];
    json.data.forEach(row => {
        let newProduct = true;
        for (let i = 0; i < products.length; i++) {
            const product = products[i];
            if(product.productID == row.productID){
                product.yearMonths.push({yearMonth: row.yearMonth, monthlySales: row.monthlySales});
                newProduct = false;
                continue;
            }
        }
        if(newProduct){
            products.push({
                productID: row.productID,
                name: row.name,
                yearMonths: [{yearMonth: row.yearMonth, monthlySales: row.monthlySales}]
            });
        }
    })

    let monthsInterval = json.monthsInterval;
    let date = new Date();
    let year = date.getFullYear();
    let month = date.getMonth() + 1;
    let xValues = getPreviousYearMonths(monthsInterval);

    xValues.forEach(yearMonth => {
        for (let i = 0; i < products.length; i++) {
            let existing = false;
            const product = products[i];
            product.yearMonths.forEach(combo => {
                if(combo.yearMonth === yearMonth){
                    existing = true;
                }
            })
            if(!existing){
                product.yearMonths.push({yearMonth: yearMonth, monthlySales: null})
            }
        }
    })

    //ソートする
    products.forEach(product => {
        product.yearMonths.sort((a, b) => {
            return a.yearMonth.localeCompare(b.yearMonth);
        });
    });

    let datasets = [];
    products.forEach(product => {
        let data = [];
        product.yearMonths.forEach(combo => {
            data.push(combo.monthlySales);
        })
        let borderColor = getRandomHSLColor();
        let fill = false;
        let label = product.name;
        datasets.push({
            label,
            data,
            borderColor,
            fill
        })
    });

    try {
        chart = new Chart(targetCanvasID, {
            type: "line",
            data: {
                labels: xValues,
                datasets: datasets
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

function addDays(date, daysToAdd){
    msInDay = 86400000;
    let ms = new Date().getTime() + (daysToAdd * 86400000);
    return new Date(ms);
}

function returnLastDayOfFebruary(){
    //今現在の年を使う
    let date = new Date();
    //3月1日に設定して、－1日を計算する
    date.setMonth(2);
    date.setDate(1);
    date = addDays(date, -1);
    return date.getDate();
}

function getPreviousYearMonths(monthsInterval){
    let date = new Date();
    let result = [];
    for (let i = 0; i < monthsInterval; i++) {
        date.setMonth(date.getMonth() - 1);
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, "0");
        result.push(`${y}-${m}`);
    }
    return result.reverse();
}

function getRandomHSLColor(){
    const h = Math.floor(Math.random() * 360);
    const s = 70;
    const l = 60;
    return `hsl(${h}, ${s}%, ${l}%)`;
}

function updateLatestChartQuery(funct, params){
    latestChartQuery = {
        funct,
        params
    }
}

function runLatestChartQuery(){
    if(!latestChartQuery.funct) return;
    latestChartQuery.funct.apply(null, latestChartQuery.params);
}

function openFullscreenCanvasPopup(){
    //万が一他のポップアップが開かれていればreturn
    if(document.getElementById("black-background").style.display == "flex") return;
    document.getElementById("black-background").style.display = "flex";
    document.getElementById("fullscreenChartDiv").style.display = "flex";
    //後ろのページのスクロールを一時停止する。
    document.getElementsByTagName("body")[0].classList.add("stop-scrolling");
    //ポップアップが完全に見えるように、トップまでスクロールする
    window.scrollTo(0, 0);
    useFullscreenCanvas = true;
    setTargetCanvasID();
}

function closeFullscreenCanvasPopup(){
    document.getElementById("black-background").style.display = "none";
    document.getElementById("fullscreenChartDiv").style.display = "none";
    //後ろのページのスクロール設定を元に戻す
    document.getElementsByTagName("body")[0].classList.remove("stop-scrolling");
    useFullscreenCanvas = false;
    setTargetCanvasID();
    runLatestChartQuery();
}

function setTargetCanvasID(){
    if(useFullscreenCanvas) targetCanvasID = "fullScreenCanvas";
    else targetCanvasID = "smallCanvas";
}

function setPieChartsMarginAuto(){
    document.getElementById("smallCanvas").style.margin = "auto";
    document.getElementById("fullScreenCanvas").style.margin = "auto";
}

function setPieChartsMarginZero(){
    document.getElementById("smallCanvas").style.margin = "0px";
    document.getElementById("fullScreenCanvas").style.margin = "0px";
}

function clearCanvas(){
    document.getElementById("groupingResultPlaceholder").innerHTML = "";
    hideFullscreenCanvasButton();
    setPieChartsMarginZero();
    if(chart) chart.destroy();
}

function showLoadingMessage(){
    document.getElementById("groupingResultPlaceholder").innerHTML = "読み込み中...";
}

function showFullscreenCanvasButton(){
    document.getElementById("fullScreenCanvasButtonHolder").style.display = "flex";
}

function hideFullscreenCanvasButton(){
    document.getElementById("fullScreenCanvasButtonHolder").style.display = "none";
}

