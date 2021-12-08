// pages/record/index.js
import Dialog from '../../miniprogram_npm/@vant/weapp/dialog/dialog';
import {
  formatTime,
  formatTimeNoTime
} from '../../utils/util'
Page({

  /**
   * 页面的初始数据
   */
  data: {
    pageNum: 0,
    operationList: [],
    bottomTip: '你已经扒拉到底了～',
    option1: [{
        text: '全部操作',
        value: 'all'
      },
      {
        text: '新增操作',
        value: 'add'
      },
      {
        text: '修改操作',
        value: 'updata'
      },
      {
        text: '删除操作',
        value: 'delete'
      },
    ],
    option2: [],
    value1: 'all',
    minDate:new Date(2021, 11, 1).getTime(),
    calendarShow: false, // 日历显示
    calendarDate: '',
    switch1_isAlltime: true,
    switch2_isToday: false,
    switch3_isDesc: false
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
    wx.showLoading({
      title: '加载中',
    })
    let _this = this;
    let desc = _this.data.switch3_isDesc ? 'asc' : 'desc';
    let type = _this.data.value1;
    let stime = '';
    let etime = '';
    let pageNum = _this.data.pageNum;
    // 如果是今天
    if (_this.data.switch2_isToday) {
      stime = formatTimeNoTime(new Date()) + ' ' + '00:00:00';
      etime = formatTimeNoTime(new Date()) + ' ' + '23:59:59';
    }else if(_this.data.switch1_isAlltime){
      // 如果是全部时间
      stime = '2000/01/01 00:00:00';
      etime = '2100/01/01 23:59:59';
    }else if(!_this.data.switch2_isToday && !_this.data.switch1_isAlltime){
      // 如果是自定义时间
      stime = _this.data.calendarDateStart + ' ' + '00:00:00';
      etime = _this.data.calendarDateEnd + ' ' + '23:59:59'
    }
    let eventData = {
      stime,
      etime,
      desc,
      type,
      pageNum
    };
    wx.cloud.callFunction({
      name: 'getRecordListBytime',
      data: eventData
    }).then(res => {
      res.result.data.map(item => {
        item.date = formatTime(new Date(item.date))
      });
      _this.setData({
        operationList: _this.data.operationList.concat(res.result.data)
      });
      wx.hideLoading()
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
        '数量：' + dataFormClick.olddata.num + dataFormClick.olddata.unit + '  ->  ' + dataFormClick.newdata.num + dataFormClick.olddata.unit : (dataFormClick.olddata.num === dataFormClick.newdata.num && dataFormClick.olddata.price !== dataFormClick.newdata.price ? '单价：' + dataFormClick.olddata.price + '元' + '  ->  ' + dataFormClick.newdata.price + '元' : '数量：' + dataFormClick.olddata.num + dataFormClick.olddata.unit + '  ->  ' + dataFormClick.newdata.num + dataFormClick.olddata.unit + ';' + '单价：' + dataFormClick.olddata.price + '元' + '  ->  ' + dataFormClick.newdata.price + '元'),
    })
  },
  onCalendarDisplay() {
    let _this = this;
    _this.setData({
      calendarShow: true
    })
  },
  onCalendarClose: function () {
    let _this = this;
    _this.setData({
      calendarShow: false
    })
  },
  formatDate(date) {
    date = new Date(date);
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  },
  onCalendarConfirm: function (event) {
    const [start, end] = event.detail;
    this.setData({
      calendarShow: false,
      calendarDate:`${this.formatDate(start)} - ${this.formatDate(end)}`,
      calendarDateStart: `${this.formatDate(start)}`,
      calendarDateEnd: `${this.formatDate(end)}`,
    });
  },

  // 全部时间switch
  onSwitch1Change: function () {
    let _this = this;
    _this.setData({
      switch1_isAlltime: !_this.data.switch1_isAlltime
    });
    if (_this.data.switch1_isAlltime) {
      _this.setData({
        switch2_isToday: false
      });
    }
  },
  // 只看今天
  onSwitch2Change: function () {
    let _this = this;
    _this.setData({
      switch2_isToday: !_this.data.switch2_isToday
    });
    if (_this.data.switch2_isToday) {
      _this.setData({
        switch1_isAlltime: false
      });
    }
  },
  // 是否倒序
  onSwitch3Change: function () {
    let _this = this;
    _this.setData({
      switch3_isDesc: !_this.data.switch3_isDesc
    })
  },
  //  点击确定开始筛选
  onConfirm: function () {
    wx.showLoading({
      title: '加载中',
    })
    let _this = this;
    if(_this.data.calendarDate === '' && !_this.data.switch1_isAlltime && !_this.data.switch2_isToday){
      wx.showToast({
        title: '请选择时间',
        icon:'error'
      });
      return;
    };
    let desc = _this.data.switch3_isDesc ? 'asc' : 'desc';
    let type = _this.data.value1;
    let stime = '';
    let etime = '';
    _this.setData({
      pageNum:0
    });
    let pageNum = _this.data.pageNum;
    // 如果是今天
    if (_this.data.switch2_isToday) {
      stime = formatTimeNoTime(new Date()) + ' ' + '00:00:00';
      etime = formatTimeNoTime(new Date()) + ' ' + '23:59:59';
    }else if(_this.data.switch1_isAlltime){
      // 如果是全部时间
      stime = '2000/01/01 00:00:00';
      etime = '2100/01/01 23:59:59';
    }else if(!_this.data.switch2_isToday && !_this.data.switch1_isAlltime){
      // 如果是自定义时间
      stime = _this.data.calendarDateStart + ' ' + '00:00:00';
      etime = _this.data.calendarDateEnd + ' ' + '23:59:59'
    }
    let eventData = {
      stime,
      etime,
      desc,
      type,
      pageNum
    };
    wx.cloud.callFunction({
      name:'getRecordListBytime',
      data:eventData
    }).then(res=>{
      console.log(res);
      // 清空当前列表
      _this.setData({
        operationList:[]
      });
      res.result.data.map(item => {
        item.date = formatTime(new Date(item.date))
      });
      _this.setData({
        operationList: _this.data.operationList.concat(res.result.data)
      });
      wx.hideLoading()
    }).catch(e=>{
      wx.showToast({
        title: '出错了',
        icon:'error'
      })
    })
  },
})