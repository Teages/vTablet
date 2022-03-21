import zh from './zh'
import en from './en'

var langList = {
  zh, en
}

var supportList = {
  zh: [
    'zh',
    'zh-cn',
  ]
}

function $t(lang, str) {
  if (lang && langList[lang]) {
    return langList[lang][str] || langList.en[str]
  }
  return langList.en[str] || '_'
}

function autoLang(languages) {
  for (let userLang of languages) {
    for (let supportLang in supportList) {
      if (supportList[supportLang].indexOf(userLang.toLowerCase()) >= 0) {
        return supportLang
      }
    }
  }
  return 'en'
}
export { $t, autoLang }