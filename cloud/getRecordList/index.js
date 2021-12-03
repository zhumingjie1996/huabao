// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
  let pageNum = event.pageNum;
  return await db.collection('operationList').orderBy('date', 'desc').skip(pageNum * 20).limit(20).get()
}