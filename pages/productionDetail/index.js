// pages/productionDetail/index.js
Page({

    /**
     * 页面的初始数据
     */
    data: {

    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        let _this = this;
        const eventChannel = this.getOpenerEventChannel()
        // 监听acceptDataFromOpenerPage事件，获取上一页面通过eventChannel传送到当前页面的数据
        eventChannel.on('acceptDataFromOpenerPage', function (data) {
            _this.setData({
                ...data
            })
        })
    },

    remove: function () {
        let _this = this;
        wx.showModal({
            title: '提示',
            content: "确定删除？",
            success(res) {
                if (res.confirm) {
                    wx.cloud.callFunction({
                        name:'removeProduction',
                        data:{
                            name:'productionList',
                            whereObj:{
                                id:_this.data.data.id
                            }
                        }
                    }).then((res) => {
                        console.log(res)
                        wx.showToast({
                            title: '删除成功',
                            icon: 'success',
                            success: function () {
                                wx.navigateBack({
                                    delta: 1,
                                })
                            }
                        })
                    })
                }
            }
        })
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