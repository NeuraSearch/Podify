import Rails from "@rails/ujs"
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// This class is responsible for the drag and drop component. This component
// is used to reorganise the order of the list of episodes within a playlist. 
export default class extends Controller {
    connect() {
        this.sortable = Sortable.create(this.element, {
            onEnd: this.end.bind(this)
        })
    }

    // Once a drag and drop has been completed, create an Ajax call to the Rails controller action
    end(event) {
        let id = document.URL.split("/").pop();
        let episode_id = event.item.id.replace('episode_','')
        let data = new FormData()
        data.append("position", event.newIndex + 1)

        Rails.ajax({
            url: this.data.get("url").replace(":id", id).replace(":episode_id", episode_id),
            type: 'PATCH',
            data: data
        })
    }
}
