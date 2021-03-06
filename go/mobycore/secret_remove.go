package mobycore

import "golang.org/x/net/context"

// SecretRemove removes a Secret.
func (cli *Client) SecretRemove(ctx context.Context, id string) error {
	resp, err := cli.delete(ctx, "/secrets/"+id, nil, nil)
	ensureReaderClosed(resp)
	return err
}
