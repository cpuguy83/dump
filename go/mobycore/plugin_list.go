package mobycore

import (
	"encoding/json"
	"net/url"

	"github.com/moby/moby-core/api/types"
	"github.com/moby/moby-core/api/types/filters"
	"golang.org/x/net/context"
)

// PluginList returns the installed plugins
func (cli *Client) PluginList(ctx context.Context, filter filters.Args) (types.PluginsListResponse, error) {
	var plugins types.PluginsListResponse
	query := url.Values{}

	if filter.Len() > 0 {
		filterJSON, err := filters.ToParamWithVersion(cli.version, filter)
		if err != nil {
			return plugins, err
		}
		query.Set("filters", filterJSON)
	}
	resp, err := cli.get(ctx, "/plugins", query, nil)
	if err != nil {
		return plugins, err
	}

	err = json.NewDecoder(resp.body).Decode(&plugins)
	ensureReaderClosed(resp)
	return plugins, err
}
