function changeIframe(my_url) {
    // Change url in top left corner
    var mydiv = document.getElementById('dynamic-url');

    let btn = document.createElement("button");
    btn.innerHTML = my_url;        // button text
    btn.title = "Open in new tab"; // text when button:hover

    // Click on button open a new tab containing the file
    // https://stackoverflow.com/questions/34082002/html-button-opening-link-in-new-tab
    btn.onclick = function(){
        window.open(
            my_url,
            '_blank' // <- This is what makes it open in a new window.
          );
        };
    
    mydiv.replaceChildren(btn);

    // Change iframe content
    document.getElementById('dynamic-iframe').src = my_url;

    // Change button style
    var all_buttons = document.getElementsByClassName("ulli_button");
    for (var i = 0; i < all_buttons.length; i++) {
        all_buttons[i].style.color = "inherit";
    }

    document.getElementById(my_url).style.color = "red";
}



