const Utils = {
  getUrl(url, callback) {
    var xhttp;
    xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
      if (this.readyState == 4 && this.status == 200) {
        callback(this);
      }
    };
    xhttp.open("GET", url, true);
    xhttp.send();
  },
  postForm(url, formElement, callback) {
    var XHR = new XMLHttpRequest();
    // Bind the FormData object and the form element
    var formData = new FormData(formElement);

    // Define what happens on successful data submission
    XHR.addEventListener("load", function(event) {
      callback(event);
    });

    // Define what happens in case of error
    XHR.addEventListener("error", function(event) {
      callback(event);
    });

    // Set up our request
    XHR.open("POST", url);

    // The data sent is what the user provided in the form
    XHR.send(formData);
  },
  toggleZindex(element, zIndex) {
    element.style.zIndex = zIndex
  }
}