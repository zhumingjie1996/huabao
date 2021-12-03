// pages/record/index.js
import Dialog from '../../miniprogram_npm/@vant/weapp/dialog/dialog';
import {
  formatTime
} from '../../utils/util'
Page({

  /**
   * 页面的初始数据
   */
  data: {
    pageNum: 0,
    operationList: [],
    bottomTip: '你已经扒拉到底了～'
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    let _this = this;
    _this.getOperationList();
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function () {
    let _this = this;
    _this.setData({
      operationList: [],
      pageNum: 0
    });
    _this.getOperationList();
  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function () {
    let _this = this;
    _this.setData({
      pageNum: _this.data.pageNum + 1
    });
    _this.getOperationList();
  },

  getOperationList: function () {
    let _this = this;
    wx.cloud.callFunction({
      name: 'getRecordList',
      data: {
        pageNum: _this.data.pageNum
      }
    }).then(res => {
      res.result.data.map(item => {
        item.date = formatTime(new Date(item.date))
      });
      _this.setData({
        operationList: _this.data.operationList.concat(res.result.data)
      });
    }).then(() => {
      wx.stopPullDownRefresh()
    })
  },
  showUpdataDetail(e) {
    if (e.currentTarget.dataset.type !== 'updata') return;
    console.log(e.currentTarget.dataset);
    let dataFormClick = e.currentTarget.dataset;
    Dialog.alert({
      title: dataFormClick.olddata.name + ' ' + dataFormClick.olddata.spec,
      message: dataFormClick.olddata.price === dataFormClick.newdata.price && dataFormClick.olddata.num !== dataFormClick.newdata.num ?
        '数量：' + dataFormClick.olddata.num + dataFormClick.olddata.unit + '  ->  ' + dataFormClick.newdata.num + dataFormClick.olddata.unit :
        (dataFormClick.olddata.num === dataFormClick.newdata.num && dataFormClick.olddata.price !== dataFormClick.newdata.price ? '单价：' + dataFormClick.olddata.price + '元' + '  ->  ' + dataFormClick.newdata.price + '元' : '数量：' + dataFormClick.olddata.num + dataFormClick.olddata.unit + '  ->  ' + dataFormClick.newdata.num + dataFormClick.olddata.unit + ';' + '单价：' + dataFormClick.olddata.price + '元' + '  ->  ' + dataFormClick.newdata.price + '元'),
    })
  }
})