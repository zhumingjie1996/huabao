// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init();

const db = cloud.database();
const $ = db.command.aggregate

// 云函数入口函数
exports.main = async (event, context) => {
    // return db.collection("productionList").get()
    return await db.collection("productionList").aggregate()
    .group({
        _id: {
            // id:'$initials',
            name:'$name'
        },
        master_data: $.push('$$ROOT'),
        initials:$.addToSet('$initials')
        // mergedVolume: $.mergeObjects('$')
    })
    .group({
        _id:{
            initials:'$initials'
        },
        master_data: $.push('$master_data'),
    })
    .sort({_id:1})
    .limit(10000)
    .end();
}