import preferences from '@ohos.data.preferences';

// 数据持久化：用户偏好
class PreferencesUtil {
  // Q: 可以用Object么？
  prefMap: Map<string, preferences.Preferences> = new Map()

  // 加载数据
  async loadPreferences(context, name: string) {
    // 异步写法
    // preferences.getPreferences(context, name)
    //   .then(pref => {
    //     this.prefMap.set(name, pref)
    //     console.log('testTag', `加载Preferences[${name}]成功`)
    //   })
    //   .catch(reason => {
    //     console.log('testTag', `加载Preferences[${name}]失败`, JSON.stringify(reason))
    //   })

    try { // 使用 async/await 转化为同步方法
      let pref = await preferences.getPreferences(context, name)
      this.prefMap.set(name, pref)
      console.log('testTag', `加载Preferences[${name}]成功`)
    } catch (e) {
      console.log('testTag', `加载Preferences[${name}]失败`, JSON.stringify(e))
    }
  }

  // 写数据
  async putPreferenceValue(name: string, key: string, value: preferences.ValueType) {
    if (!this.prefMap.has(name)) {
      console.log('testTag', `Preferences[${name}]尚未初始化`)
      return
    }
    try {
      let pref = this.prefMap.get(name)
      // 写入数据
      await pref.put(key, value)
      // 刷盘
      await pref.flush()
      console.log('testTag', `保存Preferences[${name}.${key} = ${value}]成功`)
    } catch (e) {
      console.log('testTag', `保存Preferences[${name}.${key} = ${value}]失败`, JSON.stringify(e))
    }
  }

  // 读数据
  async getPreferenceValue(name: string, key: string, defaultValue: preferences.ValueType) {
    if (!this.prefMap.has(name)) {
      console.log('testTag', `Preferences[${name}]尚未初始化`)
      return
    }
    try {
      let pref = this.prefMap.get(name)
      // 读数据
      let value = await pref.get(key, defaultValue)
      console.log('testTag', `读取Preferences[${name}.${key} = ${value}]成功`)
      return value
    } catch (e) {
      console.log('testTag', `读取Preferences[${name}.${key}]失败`, JSON.stringify(e))
    }
  }
}

const preferencesUtil = new PreferencesUtil()

export default preferencesUtil as PreferencesUtil