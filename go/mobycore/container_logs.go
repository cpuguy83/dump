package mobycore

import (
	"io"
	"net/url"
	"time"

	"golang.org/x/net/context"

	"github.com/moby/moby-core/api/types"
	timetypes "github.com/moby/moby-core/api/types/time"
)

// ContainerLogs returns the logs generated by a container in an io.ReadCloser.
// It's up to the caller to close the stream.
func (cli *Client) ContainerLogs(ctx context.Context, container string, options types.ContainerLogsOptions) (io.ReadCloser, error) {
	query := url.Values{}
	if options.ShowStdout {
		query.Set("stdout", "1")
	}

	if options.ShowStderr {
		query.Set("stderr", "1")
	}

	if options.Since != "" {
		ts, err := timetypes.GetTimestamp(options.Since, time.Now())
		if err != nil {
			return nil, err
		}
		query.Set("since", ts)
	}

	if options.Timestamps {
		query.Set("timestamps", "1")
	}

	if options.Details {
		query.Set("details", "1")
	}

	if options.Follow {
		query.Set("follow", "1")
	}
	query.Set("tail", options.Tail)

	resp, err := cli.get(ctx, "/containers/"+container+"/logs", query, nil)
	if err != nil {
		return nil, err
	}
	return resp.body, nil
}
