// pages/search/index.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
        value:""
    },
    change:function(e){
        wx.cloud.callFunction({
            name:'searchProduction',
            data:{
                key:e.detail
            }
        }).then(res=>{
            let searchList = res.result.data;
            this.setData({
                searchList
            })
        })
    },
    showDetail:function(e){
        console.log(e);
        wx.navigateTo({
          url: '../productionDetail/index',
          success: function(res) {
            // 通过eventChannel向被打开页面传送数据
            res.eventChannel.emit('acceptDataFromOpenerPage', { data: e.currentTarget.dataset })
          }
        })
      },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {

    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {

    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        let _this = this;
        let e = {detail:_this.data.value}
        _this.change(e);
    },

    /**
     * 生命周期函数--监听页面隐藏
     */
    onHide: function () {

    },

    /**
     * 生命周期函数--监听页面卸载
     */
    onUnload: function () {

    },

    /**
     * 页面相关事件处理函数--监听用户下拉动作
     */
    onPullDownRefresh: function () {

    },

    /**
     * 页面上拉触底事件的处理函数
     */
    onReachBottom: function () {

    },

    /**
     * 用户点击右上角分享
     */
    onShareAppMessage: function () {

    }
})