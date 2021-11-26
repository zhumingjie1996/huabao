// pages/productionDetail/index.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
        isChange:false
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        let _this = this;
        const eventChannel = this.getOpenerEventChannel()
        // 监听acceptDataFromOpenerPage事件，获取上一页面通过eventChannel传送到当前页面的数据
        eventChannel.on('acceptDataFromOpenerPage', function (data) {
            console.log(data);
            _this.setData({
                ...data.data
            })
        })
    },

    // 只在修改了指定的参数之后才显示提交按钮
    onChange:function(){
        let _this = this;
        if(_this.data.isChange) return;
        _this.setData({
            isChange:true
        })
    },
    onChangeStepper:function(e){
        let _this = this;
        let changeNum = e.detail;
        _this.setData({
            num:changeNum
        })
        if(_this.data.isChange) return;
        _this.setData({
            isChange:true
        });
        
    },

    // 提交修改
    commitChange:function(){
        let _this = this;
        wx.showLoading();
        wx.cloud.callFunction({
            name:"updataProduction",
            data:{
                id:_this.data.id,
                num:_this.data.num,
                price:_this.data.price
            }
        }).then(()=>{
            wx.hideLoading({
              success: (res) => {
                  wx.showToast({
                    title: '修改成功',
                    icon:'success'
                  })
              },
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
                                id:_this.data.id
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