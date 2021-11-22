// app.js
App({
  onLaunch() {
    // 云开发初始化
    wx.cloud.init({
      env:"cloud1-0gywffnb155432e2"
    })
  },
  globalData: {
    userInfo: null
  }
})
