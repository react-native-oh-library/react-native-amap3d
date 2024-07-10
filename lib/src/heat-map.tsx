
import AHeatMap ,{HeatMapProps} from './heat-mapNativeComponent'
import React , {Component}  from 'react';


export default class HatMap extends Component<HeatMapProps> {
 
  constructor(props: HeatMapProps) {
    super(props);
  }

  render() {
    return (
      <AHeatMap {...this.props} />
    );
  }
}
