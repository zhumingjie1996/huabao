// pages/add/add.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
        name: "",
        nameCode: "",
        spec: "",
        num: "",
        unit: "",
        price: "",
    },

    commit: function () {
        let _this = this;
        if (_this.data.name === '' || _this.data.nameCode === '' || _this.data.spec === '' || _this.data.num === '' || _this.data.unit === '' || _this.data.price === '') {
            wx.showToast({
                title: '请完善信息',
                icon: 'error'
            });
            return;
        }
        wx.showLoading();
        wx.cloud.callFunction({
                name: 'getProductionByName',
                data: {
                    name: _this.data.name,
                    spec: _this.data.spec
                }
            }).then(res => {
                console.log(res);
                if (res.result.data && res.result.data.length === 0) {
                    return wx.cloud.callFunction({
                        name: 'addProduction',
                        data: {
                            ..._this.data,
                            initials: _this.data.nameCode.substr(0, 1),
                            // initialsChartAt:_this.data.nameCode.substr(0,1).charCodeAt()
                        }
                    })
                }else{
                    throw 'has added'
                }
            }).then(() => {
                wx.hideLoading();
                wx.showToast({
                    title: '添加成功',
                    icon: 'success'
                });
                _this.setData({
                    name: "",
                    nameCode: "",
                    spec: "",
                    num: "",
                    unit: "",
                    price: "",
                })
            }).catch(e=>{
                wx.hideLoading({
                  success: (res) => {
                      wx.showToast({
                        title: '勿重复添加',
                        icon:'error'
                      })
                  },
                })
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