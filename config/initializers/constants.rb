if Rails.env.production?
  CLIENT_CALLBACK_URL = 'https://qbosync.netlify.app/'
  QBO_REDIRECT_URL = 'https://qboapi.tk/'
else
  CLIENT_CALLBACK_URL = nil
  QBO_REDIRECT_URL = nil
end