function changeIframe(my_url) {
    // Change url in top left corner
    var mydiv = document.getElementById('dynamic-url');
    mydiv.replaceChildren(my_url);

    // Change iframe content
    document.getElementById('dynamic-iframe').src = my_url;
}
