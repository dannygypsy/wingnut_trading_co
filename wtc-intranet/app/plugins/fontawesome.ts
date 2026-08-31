import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { faMoneyBillWave, faShoppingCart, faBoxes, faTriangleExclamation, faRightFromBracket, faUser, faChevronRight, faArrowTrendUp, faArrowTrendDown, faScaleBalanced, faReceipt, faPlus, faPencil } from '@fortawesome/pro-solid-svg-icons'

library.add(faMoneyBillWave, faShoppingCart, faBoxes, faTriangleExclamation, faRightFromBracket, faUser, faChevronRight, faArrowTrendUp, faArrowTrendDown, faScaleBalanced, faReceipt, faPlus, faPencil)

export default defineNuxtPlugin((nuxtApp) => {
    nuxtApp.vueApp.component('FaIcon', FontAwesomeIcon)
})