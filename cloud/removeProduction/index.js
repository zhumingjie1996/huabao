// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
    let collectionName = event.name;
    let whereObj = event.whereObj;
    let date = db.serverDate();
    return await db.collection(collectionName).doc(whereObj.id).remove().then(()=>{
        db.collection('operationList').add({
            data:{
                ...whereObj,
                operateType:'delete',
                operateName:'删除',
                productionId:whereObj.id,
                date
            }
        })
    })
}