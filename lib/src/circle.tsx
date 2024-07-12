
import AMapCircle ,{CircleProps} from './circleNativeComponent'
import React , {Component}  from 'react';


export default class Circle extends Component<CircleProps> {
 
  constructor(props: CircleProps) {
    super(props);
  }

  render() {
    return (
      <AMapCircle {...this.props} />
    );
  }
}
