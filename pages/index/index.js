// index.js
// 获取应用实例
const app = getApp()

Page({
  data: {
    list:[],
    productionList:[]
  },
  getProductionList:function(){
    let _this = this;
    wx.showLoading();
    wx.cloud.callFunction({
      name:'getProduction'
    }).then(res=>{
      _this.setData({
        productionList:res.result.list
      });
      return res.result.list
    }).then(res=>{
      let list = [];
      res.map((item)=>{
        list.push(item._id)
      });
      return list;
    }).then(res=>{
      _this.setData({
        list:res
      });
      wx.hideLoading()
    })
  },
  onLoad() {},
  onShow(){
    let _this = this;
    _this.getProductionList();
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
  }
})