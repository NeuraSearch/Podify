window.like_click = function(like_id, dislike_id) {
    var like_svg = document.getElementById(like_id);
    var dislike_svg = document.getElementById(dislike_id);
    like_svg.classList.add("fill-blue-500");
    dislike_svg.classList.remove("fill-red-500");
}

window.dislike_click = function(like_id, dislike_id) {
    var like_svg = document.getElementById(like_id);
    var dislike_svg = document.getElementById(dislike_id);
    like_svg.classList.remove("fill-blue-500");
    dislike_svg.classList.add("fill-red-500");
}

window.neutral_click = function(like_id, dislike_id) {
    var like_svg = document.getElementById(like_id);
    var dislike_svg = document.getElementById(dislike_id);
    like_svg.classList.remove("fill-blue-500");
    dislike_svg.classList.remove("fill-red-500");
}
