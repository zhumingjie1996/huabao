// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();

// 云函数入口函数
exports.main = async (event, context) => {
    let id = event.id;
    let date = db.serverDate();
    let oldData = {};
    return await db.collection('productionList').where({
            _id: id
        }).get()
        .then(res => {
            oldData = res.data[0];
            db.collection('productionList').where({
                    _id: id
                })
                .update({
                    data: {
                        num: event.num,
                        price: event.price
                    }
                })
        })
        .then(() => {
            db.collection('operationList').add({
                data: {
                    productionId: id,
                    operateType: 'updata',
                    operateName: '修改',
                    date,
                    oldData,
                    newData:event
                }
            })
        })
}