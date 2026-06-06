import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    appId: String,
    index: String,
    searchKey: String
  }

  connect() {
    const client = window.algoliasearch(this.appIdValue, this.searchKeyValue)

    this.search = window.instantsearch({
      indexName: this.indexValue,
      searchClient: client,
      routing: true
    })

    const {
      searchBox, hits, refinementList, menuSelect,
      stats, sortBy, pagination, clearRefinements, configure
    } = window.instantsearch.widgets

    this.search.addWidgets([
      searchBox({
        container: "#searchbox",
        placeholder: "Titre, genre, studio…",
        autofocus: true,
        showLoadingIndicator: true
      }),

      stats({
        container: "#stats",
        templates: {
          text: ({ nbHits }) =>
            nbHits === 0 ? "Aucun résultat" : `${nbHits.toLocaleString("fr-FR")} animes`
        }
      }),

      sortBy({
        container: "#sort-by",
        items: [
          { label: "Pertinence",      value: this.indexValue },
          { label: "Année ↓",         value: "animes_by_year_desc" },
          { label: "Score croissant", value: "animes_by_score_asc" }
        ]
      }),

      refinementList({
        container: "#genres-list",
        attribute: "genre_names",
        searchable: true,
        searchablePlaceholder: "Chercher un genre…",
        showMore: true,
        showMoreLimit: 50,
        sortBy: ["count:desc", "name:asc"]
      }),

      refinementList({
        container: "#studios-list",
        attribute: "studio_names",
        searchable: true,
        searchablePlaceholder: "Chercher un studio…",
        showMore: true,
        showMoreLimit: 30,
        sortBy: ["count:desc"]
      }),

      refinementList({
        container: "#year-menu",
        attribute: "year",
        sortBy: ["name:desc"],
        limit: 10
      }),

      menuSelect({
        container: "#status-menu",
        attribute: "status"
      }),

      clearRefinements({
        container: "#clear-filters",
        templates: { resetLabel: "Effacer les filtres" }
      }),

      hits({
        container: "#hits",
        templates: {
          item: (hit) => `
            <article class="anime-card">
              <a href="/animes/${hit.objectID}">
                <img src="${hit.image_url}" alt="${hit.title}" loading="lazy" />
                <div class="anime-card__body">
                  <div class="anime-card__title">
                    ${window.instantsearch.highlight({ attribute: "title", hit })}
                  </div>
                  ${hit.title_english && hit.title_english !== hit.title
                    ? `<div class="anime-card__sub">${hit.title_english}</div>`
                    : ""}
                  <div class="anime-card__tags">
                    ${(hit.genre_names || []).slice(0, 2).map(g =>
                      `<span class="tag tag--genre">${g}</span>`
                    ).join("")}
                  </div>
                  <div class="anime-card__footer">
                    <span class="score">★ ${hit.score ?? "N/A"}</span>
                    <span class="episodes">${hit.episodes ? hit.episodes + " ep." : hit.year ?? ""}</span>
                  </div>
                </div>
              </a>
            </article>
          `,
          empty: () => `
            <div class="no-results">
              <p>Aucun anime trouvé.</p>
              <p>Essaie avec un titre, un genre ou un studio différent.</p>
            </div>
          `
        }
      }),

      pagination({
        container: "#pagination",
        totalPages: 20,
        padding: 2
      }),

      configure({
        hitsPerPage: 24,
        attributesToRetrieve: [
          "title", "title_english", "synopsis",
          "score", "year", "image_url", "status",
          "episodes", "genre_names", "objectID"
        ]
      })
    ])

    requestAnimationFrame(() => this.search.start())
  }

  disconnect() {
    this.search?.dispose()
  }
}
