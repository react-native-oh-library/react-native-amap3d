
import AMapMultiPoint ,{MultiPointProps} from './multi-pointNativeComponent'
import React , {Component}  from 'react';


export default class MultiPoint extends Component<MultiPointProps> {
 
  constructor(props: MultiPointProps) {
    super(props);
  }

  render() {
    return (
      <AMapMultiPoint {...this.props} />
    );
  }
}
