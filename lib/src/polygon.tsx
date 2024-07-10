
import AMapPolygon ,{PolygonProps} from './polygonNativeComponent'
import React , {Component}  from 'react';


export default class Polygon extends Component<PolygonProps> {
 
  constructor(props: PolygonProps) {
    super(props);
  }

  render() {
    return (
      <AMapPolygon {...this.props} />
    );
  }
}
