document.addEventListener("DOMContentLoaded", () => {
    const para = document.getElementById("textPara");
    const btn = document.getElementById("highlightBtn");

    btn.addEventListener("click", () => {
        para.classList.toggle("highlight");
    });
});
