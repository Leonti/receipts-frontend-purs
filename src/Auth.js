var webAuth = new auth0.WebAuth({
  domain: 'leonti.au.auth0.com',
  clientID: 'Q4xpr2NkkxykaSde6Bgw1pgYdX9yaBMO',
  responseType: 'token id_token',
  scope: 'openid email',
  audience: 'receipts-backend',
  redirectUri: window.location.href
});

function setSession(authResult) {
  var expiryTimeMs = authResult.expiresIn * 1000 + new Date().getTime();

  localStorage.setItem('access_token', authResult.accessToken);
  localStorage.setItem('id_token', authResult.idToken);
  localStorage.setItem('expires_at', JSON.stringify(expiryTimeMs));

  document.cookie = 'access_token=' + authResult.accessToken + '; expires=' + new Date(expiryTimeMs).toUTCString()
}

function isAuthenticated() {
  var expiresAt = JSON.parse(localStorage.getItem('expires_at'));
  return (new Date().getTime() + 300 * 1000) < expiresAt;
}

exports._handleAuthentication = function handleAuthentication(onError, onSuccess) {

  console.log(location.href)

  webAuth.parseHash(function(err, authResult) {
    if (authResult && authResult.accessToken && authResult.idToken) {
      window.location.hash = '';
      setSession(authResult);
      onSuccess();
    } else if (err) {
      console.log(JSON.stringify(err));
      onError(new Error(err.error));
    }
  });

  return function (cancelError, cancelerError, cancelerSuccess) { };
}

exports._isAuthCallback = function() {
  return window.location.hash.indexOf('access_token') > 0
}

exports._login = function() {
  webAuth.authorize();
}

exports._logout = function() {
  localStorage.removeItem('access_token');
  localStorage.removeItem('id_token');
  localStorage.removeItem('expires_at');
  webAuth.logout({
    returnTo: window.location.href
  })
}

exports._getRenewedAccessToken = function(toRight, toLeft) {
  return function (onError, onSuccess) {

    webAuth.checkSession({},
      function(err, result) {
        if (err) {
          console.log(err)
          onSuccess(toLeft(err.error_description));
        } else {
          setSession(result);
          onSuccess(toRight(localStorage.getItem('access_token')))
        }
      }
    );

    return function (cancelError, cancelerError, cancelerSuccess) {};
  };
}

exports._getCachedAccessToken = function(toRight, toLeft) {
  return function (onError, onSuccess) {

    if (!isAuthenticated()) {
      onSuccess(toLeft('User is not authenticated, or token has expired'))
    } else {
      onSuccess(toRight(localStorage.getItem('access_token')))
    }

    return function (cancelError, cancelerError, cancelerSuccess) {};
  };
}
