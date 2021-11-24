// 云函数入口文件
const cloud = require('wx-server-sdk')

cloud.init()

const db = cloud.database()
// 云函数入口函数
exports.main = async (event, context) => {
    const _ = db.command
    return await db.collection('productionList')
        .where(_.or([{
            nameCode: db.RegExp({
                regexp: '.*' + event.key,
                options: 'i',
            })
        }, {
            name: db.RegExp({
                regexp: '.*' + event.key,
                options: 'i',
            })
        }, {
            spec: db.RegExp({
                regexp: '.*' + event.key,
                options: 'i',
            })
        }]))
        .limit(20)
        .get()
}