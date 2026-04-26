import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import CallDropdownController from "controllers/call_dropdown_controller"
import CatalogAnimationController from "controllers/catalog_animation_controller"

eagerLoadControllersFrom("controllers", application)
application.register("call-dropdown", CallDropdownController)
application.register("catalog-animation", CatalogAnimationController)
