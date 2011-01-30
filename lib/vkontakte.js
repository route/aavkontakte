function vkInit(id) {
  window.vkAsyncInit = function() {
    VK.init({
      apiId: id,
      nameTransportPath: '/xd_receiver.html'
    });
  };

  setTimeout(function() {
    var el = document.createElement("script");
    el.type = "text/javascript";
    el.src = "http://vkontakte.ru/js/api/openapi.js";
    el.async = true;
    document.getElementById("vk_api_transport").appendChild(el);
  }, 0);
}

function vkLogin(options) {
  VK.Auth.login(function(response) {
    if(response.session) {
      /* User is logged in */
      // need ajax request? $.post(url, response, "script" );
      post(options['url'], response, options['authenticity_token'], options['session_name'], options['session_key']);
      if (response.settings){ /* Selected user access settings */ }
    }
    else { /* User pressed the Cancel button */ }
  }, VK.access.FRIENDS | VK.access.WIKI);
  return false;
}

function post(url, params, token, session_name, session_key) {
  var method = "post";

  var form = document.createElement("form");
  form.setAttribute("method", method);
  form.setAttribute("action", url);

  var authField = document.createElement("input");
  authField.setAttribute("type", "hidden");
  authField.setAttribute("name", "authenticity_token");
  authField.setAttribute("value", token);
  form.appendChild(authField);

    var sessionField = document.createElement("input");
  sessionField.setAttribute("type", "hidden");
  sessionField.setAttribute("name", session_name);
  sessionField.setAttribute("value", session_key);
  form.appendChild(sessionField);

  // recursively adds nested inputs to form 
  var add_inputs = function (form, object, parent_name) {
    parent_name = parent_name || "";
    for (var key in object) {
      var hiddenField = document.createElement("input");
      hiddenField.setAttribute("type", "hidden");
      if (typeof(object[key]) == "object") add_inputs(form, object[key], parent_name ? parent_name + "[" + key + "]" : key);
      else {
        hiddenField.setAttribute("name", parent_name ? parent_name + "[" + key + "]" : key);
        hiddenField.setAttribute("value", object[key]);
      }
      form.appendChild(hiddenField);
    }
  }

  add_inputs(form, params);

  document.body.appendChild(form);  // Not entirely sure if this is necessary
  form.submit();
}
