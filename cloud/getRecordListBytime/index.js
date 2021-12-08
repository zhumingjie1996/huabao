// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
  let {
    stime,
    etime,
    desc,
    type,
    pageNum
  } = event;
  if (type === 'all') {
    return await db.collection('operationList')
    .where({
      date:db.command.gte(new Date(stime)).and(db.command.lte(new Date(etime)))
    })
    .orderBy('date', desc)
    .skip(pageNum * 20)
    .limit(20)
    .get()
  } else {
    return await db.collection('operationList')
      .where({
        date:db.command.gte(new Date(stime)).and(db.command.lte(new Date(etime))),
        operateType:type
      })
      .orderBy('date', desc)
      .skip(pageNum * 20)
      .limit(20)
      .get()
  }
}