// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
    let id = event.id
    db.collection('productionList').where({
            _id: id
        })
        .update({
            data: {
                num: event.num,
                price: event.price
            }
        })
}