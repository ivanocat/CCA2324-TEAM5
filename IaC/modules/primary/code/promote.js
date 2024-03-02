const AWS = require('aws-sdk');
const autoscaling = new AWS.AutoScaling();
const rds = new AWS.RDS();

exports.handler = async (event) => {
    
    const asgParams = {
        AutoScalingGroupName: 'nombre-del-asg',
        MinSize: 1,
        MaxSize: 2,
        DesiredCapacity: 2
    };

    // Promover la réplica de lectura en RDS
    const rdsParams = {
        DBInstanceIdentifier: 'nombre-de-la-replica-de-lectura'
    };

    try {
        await autoscaling.updateAutoScalingGroup(asgParams).promise();
        await rds.promoteReadReplica(rdsParams).promise();
        return { statusCode: 200, body: 'Parámetros del ASG cambiados y réplica de lectura promocionada exitosamente' };
    } catch (err) {
        console.error(err);
        return { statusCode: 500, body: 'Error al cambiar los parámetros del ASG o promocionar la réplica de lectura' };
    }
};
