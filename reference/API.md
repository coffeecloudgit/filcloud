
# fil-admin

## 📦 APP 接口中文文档V1

### 1.登录
#### 1.1 获取登录验证码

**请求地址**

> http://192.168.103.106:8000/api/v1/captcha

**请求类型**
GET

**必要授权**

无

**请求参数**


| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| accesskey | String | 否      | accesskey |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data         | String  | 是      | ... | 返回数据     |
| id           | String  | 是      | FA9sAn... |      |
| msg          | String  | 是      | success |      |
| requestId    | String  | 是      |  |      |

**返回示例**

```bash
{
    "code": 200,
    "data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPAAAABQCAMAAAAQlwhOAAAA81BMVEUAAABnEV+MNoRnEV+6ZLLGcL7SfMrZg9F/KXevWadjDVtkDlxZA1Hkjtx6JHK5Y7GuWKZzHWtuGGZbBVOfSZdoEmDDbbvhi9mvWaejTZu5Y7FxG2loEmDKdMKlT53kjtzPecd3IW+AKnjqlOJsFmRdB1WOOIafSZeXQY+rVaOtV6XokuCWQI56JHLgitjlj91gCli+aLZzHWu9Z7W6ZLLtl+WkTpx5I3FZA1FkDlyGMH6iTJqiTJqgSpiwWqjqlOJzHWtqFGLRe8liDFphC1msVqScRpSdR5WvWadqFGKqVKKVP42nUZ+mUJ52IG6VP423Ya+qsqY7AAAAAXRSTlMAQObYZgAABjxJREFUeJzsXN1O4zwQ9egTVKtWSAVlBbRSRbsIJFaI/xYkthcVacUF7/84n5ofe8YeO3bqpEG752K3dRxnTs7MeOykiM7hEX2+5Do8t2cLATQz7OOjYnx5yTB+ft4PY4CmGKPPf4PC//APfw0u9m1AMHaL+osLO+MfO43cFGCb2KEO7ZPsXwffH11knJEtSIfh5OTEOW4nFQaQAodP4Ha+dUYLx1X4KaAEriGxY9SYw9lwdRXMuGRa0o5ih7yBjYscrjBKVpEUQWzbcGoWL9YjxCqAnmaiy+Ab15D7ZfzyYmOsTUa9HmXs0vzmhmc8KbNBGzFsg5WvJgL0CF1x54pqji+IyWQCRcLfo0tn+Gm06NUG4KkEAO7u7vJE5m03AEzK7nvn+5NjTG0i8SwV9jecjIe//K5hcFrjHAKLwqQBK3wgY9G7hKAZEPH9nTO+DzA3TXdmbAIZdVY0SH88ODjIPlc5NZFUcAKPS4Xv74MYhzDxArbv7CxjXIq5NfZAicVJPNKOaOGB+I7HZWMI3yaAbTzDDTRwc8+e0XNHo5Ees4IEsLqZ4wYpIFSHHeOpWGEgCs9mMyFOUdeRI2bzwVuEnPkrwk/Pv7zC+fct39NTvTfwLt3yjAQCKWzPsUzphxXWum7/O9WaVH1B71CrNZYq65TClusbjInCpF0wHZHCoAscm5UVAEjctLTFwlgXYoMYswqji4CmMLp57Sz9sSXFNzV12xlj0zabDSJMFRWUjU4SrY7C1kjHgQw1+zVnSrHBzG03Fc6Z9Ll0VmYGQPcVnV9rSTg/Pq7PuKoE1O+G4NO0ANHv9800C4naFlHEtWkpkPB8Pt+Bb+XUmxustbC3oM9kqSRJUGgUvPRSsvTqgafRc89+HDgBuV7a/MpJzKYtkeDcB0piMnZ+gcFg0HjW8s2MmiOwEgt+IkIOQaYjvdOWceNrYTYJP+T/3dKeoBX8vgqTog15NmrKoxua3+zgC5uHh4zx7e2t3l2KnOrzFVgUXjAJShirpdx/8FOMc6vNH3WIGgQoWIUFYpOmKZibFIzCi8UCiwaMwvLjUJV4cH5uY/zxsQNjG+EMT5ZzMpNToyjBtcSral4APWRUVdI1hsNhyR6gGYWd+erpycKYTDBIJznRwuvrq2wlu65k717dA1EqjGry6EVmxfqvUJjfQgNVLUnynMKyPAeVlUiqMkMeOUDIssmjq9dj3XILjTtbFkzokSmoock1iMTYgMTY9qK3xJt0pT/YV34E9k1SkGspMJa1MhCFttOsJ+wkSYxlpiAFiSfjKn8gtUBdAHq0SRSWdTMNcI0AjLcKm+tqegnvWHbzcawWRuI/rwsIFLnm4k5prL5rXcbjsVlnMFWHX+VrK6FKO63HRqPRf4jxNdvpnVgjnw9rlq/AsIb0GdPFv+DWYNJcb525fi7CVOHra47x+/s7tbGIVkp4tVpRS4DkYPwsWHbSDS7eWFw7LabEzH7g7SMeCitThVFornBRUka1MBKdmngNNyneSV2v1+iRonOaNpf2QXTFL59OZXgqB1fpG/cBuvIl637Lu0ClwkISrX58rG0Ug8+cJfn+8mKMSSkP1wpmKjFOdIRzxQUUCYePAzZGj5I3Jwd/vubmJJkpAGCKJUYbPTiBVyrBzQgWY8oqgI769uZmHAJAtQhuyj9Np1MVq7r9RvRasBTCuXuMjUHVPUY8vgLPUvK7UmTKTLGFBIVZX1XDL5fLYFtaBtAkZh5GbV9f1YwbMDEySHIyDxIJKvl+C+A5lzna8I7dnmCdcfxSVQNvbDSOXdJHI++ohGLT5sW6wHfTKuMADOue2Hcf7izfYU3G/X4F49iIdQcjKLyOZIoQYmY90qEY2S5GIyF7f8mCzvCNrvBRvOG+BY6OYjDu4C98rIjCN/sN158IIyEkcYeLi4zvn90Zo+cM2YsZ3UYEvvhJ0r75huym1Uad1+0bQtj+YSewo4t8P75dSAKHbV6sC3wP6zL+jGxJXNi9/9BSsdp+C1ji87M1xjX+nocjv1nWJLbfAirU5LsUwvfdyQK1/mKLI79VKhy+L2++yyWxXC4HAzvjHtfY8l9sCX/yYr6tJ9RrdE6Fez2WccuIo7D9NTqMLvCNBR++MfF/AAAA//+9TES0cIN8FAAAAABJRU5ErkJggg==",
    "id": "FA9sAn9F1HH9QebkKY00",
    "msg": "success",
    "requestId": "efd8b755-3633-48c6-b072-16d7d57f5218"
}
```

#### 1.2 登录用户中心

**请求地址**

> http://192.168.103.106:8000/api/v1/login

**请求类型**
POST

**必要授权**

无

**请求参数**


| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| username | String | 是      | username |
| password | String | 是      | password |
| code     | String | 是      | code |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| expire         | String  | 是      | ... | 返回数据     |
| token           | String  | 是      | FA9sAn9F1HH9QebkKY00 |      |

**返回示例**

```bash
{
    "code": 200, 
    "expire": "2019-08-07T12:45:48+08:00", 
    "token": ".eyJleHAiOjE1NjUxNTMxNDgsImlkIjoiYWRtaW4iLCJvcmlnX2lhdCI6MTU2NTE0OTU0OH0.-zvzHvbg0A"
    "id": "FA9sAn9F1HH9QebkKY00",
    "msg": "success",
    "requestId": "efd8b755-3633-48c6-b072-16d7d57f5218"
}
```

#### 1.3获取用户信息

**请求地址**

> http://192.168.103.106:8000/api/v1/user/getuser

**请求类型**
GET

**必要授权**

Bearer Token


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**

```bash
{
    "requestId": "930f558d-0a2a-400b-a493-c2647549f1b8",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "user": {
            "userId": 1,
            "username": "admin",
            "nickName": "admin",
            "phone": "13100000000",
            "avatar": "",
            "sex": "1",
            "email": "1@qq.com",
            "remark": "",
            "createBy": 0,
            "updateBy": 0,
            "createdAt": "0001-01-01T00:00:00Z",
            "updatedAt": "0001-01-01T00:00:00Z"
        }
    }
}
```

#### 1.4 更新用户deviceToken

**请求地址**

> http://192.168.103.106:8000/api/v1/user/device_token

**请求类型**
POST

**必要授权**

Bearer Token

**请求参数**
| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| deviceToken  | String  | 否      |        |   标签名称 |
| status       | String  | 是      |        |   默认为1，可以不传，禁用时传2 |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "56b3f9f5-c9fc-4d4f-ae2d-6e48d557067f",
    "code": 200,
    "msg": "修改成功",
    "data": 1
}
```

### 2.首页
#### 2.1 获取总算力和资产数据

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/total/

**请求类型**
GET

**请求参数**
| 参数名        | 类型      | 是否必须  | 描述       |
| :----------- | :-----   | :---     | :------- |
| deptId       | int      | 否       | 部门ID      |

**必要授权**

Bearer Token

**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "af8e4146-958c-4a7b-82b5-cb60c84be4e1",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "availableBalance": "22423.6996",       //可用余额
        "balance": "1750724.1783",              //总余额
        "sectorPledgeBalance": "1655857.1427",  //质押余额
        "vestingFunds": "73098.6357",           //存储锁仓
        "rewardValue": "738131.9682",           //总奖励数量
        "weightedBlocks": 0,                    //总报块数量
        "qualityAdjPower": "268.68",            //总算力
        "powerUnit": "PiB",                     //总算力单位
        "powerPoint": "1.14",
        "controlBalance": "0",
        "blocksMined24H": 172,                  //24H报块数量
        "totalRewards24H": "1283.3086",         //24H报块总奖励
        "luckyValue24H": "0.9466528125",        //24H幸运值
        "qualityAdjPowerDelta24H": "-280",   //24H算力增量
        "receiveAmount": "0",
        "burnAmount": "0",
        "sendAmount": "0",
        "nodesList": null,
        "roleId": 0,
        "powerDeltaUnit": "TiB",                //算力增量单位
        "powerDeltaShow": "-280 TiB"            //算力增量显示
    }
}
```

#### 2.2 获取节点列表

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/

**请求类型**
GET

**必要授权**

Bearer Token

**请求参数**

| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| pageIndex | int | 否      | 页码 |
| pageSize | int | 否       | 每页返回行数 |
| deptId       | int      | 否       | 部门ID      |

**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "87f80c7c-60c0-4c8b-a4e0-945ca12de310",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "count": 16,
        "pageIndex": 1,
        "pageSize": 10,
        "list": [
            {
                "id": 29,
                "node": "f02056257",                            //节点ID
                "msgCount": 73160,                              //总消息数
                "sectorType": "Storage Miner",
                "createTime": "2023-03-04T16:34:00+08:00",
                "availableBalance": "884.6005",                 //可用余额
                "balance": "74892.6335",                        //总余额
                "sectorPledgeBalance": "71077.5725",
                "vestingFunds": "2930.4604",
                "rewardValue": "31141.9167",
                "WeightedBlocks": 2772,
                "qualityAdjPower": "10.01",                     //算力
                "powerUnit": "PiB",                             //算力单位
                "qualityAdjPowerDelta24h": "0",                 //24H算力增量
                "powerPoint": "0.04",
                "powerGrade": "769",
                "sectorSize": "32GiB",
                "sectorStatus": "32797 全部, 32797 有效, 0 错误, 0 恢复中",
                "SectorTotal": 32797,
                "SectorEffective": 32797,
                "SectorError": 0,
                "SectorRecovering": 0,
                "status": "1",
                "type": "6",
                "endTime": "2024-09-26T17:04:53+08:00",
                "deptId": 0,
                "title": "",                                    //标签
                "chartList": null,
                "miningEfficiency": "5",                    //产出效率 单位：Fil/PiB
                "height": 0,                                    //高度
                "syncStatus": false                             //是否同步
                "powerDeltaShow": "-140 TiB"                //算力增量，带单位
                "powerDeltaUnit": "TiB"                     //算力增量单位
            },
            ...
            {}
        ]
    }
}
```

#### 2.3 获取总算力图表

**请求地址**

> http://192.168.103.106:8000/api/v1/fil-pool/app-chart/

**请求类型**
GET

**请求参数**
| 参数名        | 类型      | 是否必须  | 描述       |
| :----------- | :-----   | :---     | :------- |
| deptId       | int      | 否       | 部门ID      |

**必要授权**

Bearer Token


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "2f35c9ae-5b1d-4d1e-a77a-54f691d24af8",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "barData": [
            {
                "x": "18:00",
                "y": 0
            },
            {
                "x": "19:00",
                "y": 0
            },
            ...
        ]
    }
}
```


#### 2.4 获取总算力值和节点数

**请求地址**

> http://192.168.103.106:8000/api/v1/fil-pool/app-get/

**请求类型**
GET

**请求参数**
| 参数名        | 类型      | 是否必须  | 描述       |
| :----------- | :-----   | :---     | :------- |
| deptId       | int      | 否       | 部门ID      |

**必要授权**

Bearer Token


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "341304cb-a94f-40e1-a5e4-e44be8883bcb",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "qualityAdjPower": "269.06",   //总算力
        "nodesCount": 22               //节点数量
    }
}
```

#### 2.5 预警信息列表

**请求地址**

> http://192.168.103.106:8000/api/v1/send-msg/

**请求类型**
GET

**必要授权**

Bearer Token


**请求参数**

| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| pageIndex | int | 否      | 页码 |
| pageSize | int | 否       | 每页返回行数 |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "46e6f897-6c86-4463-b59c-0f4a4e84d772",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "count": 7,
        "pageIndex": 1,
        "pageSize": 10,
        "list": [
            {
                "id": 7,
                "title": "节点f02810687扇区错误",
                "node": "",
                "content": "节点f02810687当前算力20 Pib，错误扇区数量增加 2000。",
                "createTime": "2024-07-31T16:35:09+08:00",
                "sendTime": null,
                "type": 101,
                "sendStatus": 0
            },
            ...
        ]
    }
}
```

#### 2.6 获取用户中心总折合资产

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/finance/

**请求类型**
GET

**请求参数**
| 参数名        | 类型      | 是否必须  | 描述       |
| :----------- | :-----   | :---     | :------- |
| deptId       | int      | 否       | 部门ID      |

**必要授权**

Bearer Token


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "295baa22-5d83-4594-ae88-a6bda47bc7d5",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "availableBalance": "16503.65713137",   //可用余额
        "balance": "1176066.3633",              //账户余额
        "sectorPledgeBalance": "1657081.9218",  //扇区质押
        "vestingFunds": "73875.5315",           //锁仓金额
        "blocksMined24H": 102,                  //24小时报块数量
        "totalRewards24H": "751.9849",          //昨日新增
        "newlyPrice": "4.183"                   //当前价格
    }
}
```

#### 2.7 24小时报块图表数据

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/blockstats/

**请求类型**
GET

**请求参数**
| 参数名        | 类型      | 是否必须  | 描述       |
| :----------- | :-----   | :---     | :------- |
| deptId       | int      | 否       | 部门ID      |

**必要授权**

Bearer Token


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "6c4c14c8-e8f6-49ae-bc39-9e087629c730",
    "code": 200,
    "msg": "查询成功",
    "data": [
        {
            "blocksGrowth": 5,
            "blocksRewardGrowthFil": "36.98669147",
            "heightTimeStr": "17:00",
            "heightTime": "2024-07-31T17:00:00+08:00"
        },
        ...
    ]
}
```

#### 2.8 更新node标签

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/:id

**请求类型**
PUT

**必要授权**

Bearer Token

**请求参数**
| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| id           | int     | 是      | 1      |     id    |
| title        | String  | 是      |        |   标签名称 |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "56b3f9f5-c9fc-4d4f-ae2d-6e48d557067f",
    "code": 200,
    "msg": "修改成功",
    "data": 1
}
```

#### 2.9 孤块列表

**请求地址**

> http://192.168.103.106:8000/api/v1/block

**请求类型**
GET

**必要授权**

Bearer Token

**请求参数**
| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| pageIndex | int | 否      | 页码 |
| pageSize | int | 是       | 每页返回行数 |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "d9d243e9-aabe-4085-ab43-d7494226f2a9",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "count": 10,
        "pageIndex": 1,
        "pageSize": 10,
        "list": [
            {
                "height": 4199163,                                //高度
                "node": "f02246008",                              //节点
                "blockTime": "2024-08-22 07:01:13",      
                "message": "bafy2bzacecgekxj4iq6d56gtkbrhlnq3jgklltixtl4k52zidyklibdlsr5gq",
                "rewardValue": "0.00000000",               //孤块数量为0
                "status": "2"
            },
            ...
        ]
    }
}
```

#### 2.10 获取价格

**请求地址**

> http://192.168.103.106:8000/api/v1/filprice

**请求类型**
GET

**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "6a80f6cd-cd08-407e-8c98-a6867a1d8805",
    "code": 200,
    "msg": "success",
    "data": {
        "newlyPrice": 3.575,         //filusdt价格 $
        "percentChange": -0.72,      //24h涨跌幅 %
        "flowTotal": "22.7亿",       //24h成交额
        "cnyRate": 7.11,             //Cny-usd汇率
        "cnyPrice": 25.41            //filcny价格  ￥
    }
}
```

#### 2.11 扇区详情

**请求地址**

> http://192.168.103.106:8000/api/v1/nodes-app/sectors

**请求类型**
POST

**必要授权**

Bearer Token

**请求参数**
| 参数名     | 类型    | 是否必须 | 描述   |
| :-------- | :----- | :---    | :-------- |
| pageIndex | int | 否      | 页码 |
| pageSize | int  | 否      | 每页返回行数,默认返回10条 |
| node     | string | 是       | 节点名称 |


**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "c36e12ee-e43e-49e7-855c-539beac77451",
    "code": 200,
    "msg": "查询成功",
    "data": {
        "count": 36,
        "pageIndex": 1,
        "pageSize": 10,
        "list": {
            "miner": "f02812504",                                           //节点名称
            "sector_size": "64 GiB",                                        //扇区大小
            "sector_status": "81,043 全部,  81,043 有效,  0 错误,  0 恢复中",  //扇区状态
            "sector_effective": 69074,
            "sectors": [
                {
                    "day": "2025-11-06",                    //扇区列表： 到期日
                    "from": 0,
                    "to": 7,
                    "sectorNum": 8,       
                    "fromTo": "0-7",                        //扇区区间
                    "power": "512GiB"                       //算力
                },
                ...
            ]
        }   
    }
}
```

### 3.部门切换
#### 3.1 获取部门列表

**请求地址**

> http://192.168.103.106:8000/api/v1/dept/list

**请求类型**
GET

**必要授权**

Bearer Token

**返回结果**

| 参数名        | 类型     | 是否必须 | 示例    | 描述       |
| :----------- | :-----  | :---    | :---   | :------- |
| code         | String  | 是      | 200     |  |
| data           | String  | 是      |  |      |

**返回示例**
```bash
{
    "requestId": "33a95147-0b02-454b-93c5-99ff7d042ec3",
    "code": 200,
    "msg": "查询成功",
    "data": [
        {
            "deptId": 8,
            "deptName": "KC",
            "parentId": 1,
            "status": 2
        },
        {
            "deptId": 12,
            "deptName": "KF",
            "parentId": 11,
            "status": 2
        }
    ]
}
```