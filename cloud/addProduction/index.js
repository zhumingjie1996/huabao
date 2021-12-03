// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
    let data = event;
    let date = db.serverDate();
    return await db.collection('productionList').add({
        data,
    }).then(res=>{
        db.collection('operationList').add({
            data:{
                ...data,
                date,
                operateType:'add',
                operateName:'新增',
                productionId:res._id
            }
        })
    })
}